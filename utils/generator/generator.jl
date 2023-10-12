using Base.Filesystem
using YAML
using TextWrap

const linewidth = 92

const julia_ctype = Dict(
                          "int" => "Cint",
                          "void" => "Cvoid"
                        )


function maxlength(key, vec) 
    (max, _) = findmax(x -> textwidth(x[key]), vec)
    return max
end


function write_signature_c(io, fct_spec)
    # return type
    if haskey(fct_spec, "return")
        write(io, fct_spec["return"]["ctype"])
    else
        write(io, "void")
    end

    # name
    write(io, " ", fct_spec["name"], "(")

    # arguments
    for (iarg, arg) in enumerate(fct_spec["args"])
        write(io, arg["ctype"], " ", arg["name"])
        if iarg < length(fct_spec["args"])
            write(io, ", ")
        end
    end
    write(io, ")")
end


function write_signature_f90(io, fct_spec)
    #subroutine trixi_finalize_simulation(handle) bind(c)
    #  use, intrinsic :: iso_c_binding, only: c_int
    #  integer(c_int), value, intent(in) :: handle
    #end subroutine
end

function enum_name(fct_name)
    return "TRIXI_FPTR_" * uppercase(chopprefix(fct_name, "trixi_"))
end

function write_fptr_enum(io, fct_spec)
    
    println(io, "    ", enum_name(fct_spec["name"]), ",")
end


function write_fptr_name(io, fct_spec)
    
    println(io, "    ", rpad("[" * enum_name(fct_spec["name"]) * "]", 36),
                "= \"", fct_spec["name"], "_cfptr\",")
end


function write_trixi_h(io, fct_spec)
    # signature
    write_signature_c(io, fct_spec)
    write(io, ";\n")
end


function write_api_c(io, fct_spec)

    # doxygen header
    println(io, "/**")
    println(io, " * @anchor ", fct_spec["name"], "_api_c" )
    println(io, " *")
    println(io, " * @brief ", fct_spec["doc_brief"])
    println(io, " *")

    # doxygen detailed doc
    if haskey(fct_spec, "doc_detail")
        TextWrap.println_wrapped(io, fct_spec["doc_detail"], width=linewidth,
                                 initial_indent = " * ", subsequent_indent = " * ")
    end
    println(io, " *")

    # doxygen parameters
    if haskey(fct_spec, "args")
        pad_name = maxlength("name", fct_spec["args"])
        pad_intent = maxlength("intent", fct_spec["args"]) + 2
        for arg in fct_spec["args"]
            write(io, " * @param")
            if haskey(arg, "intent")
                write(io, rpad("[" * arg["intent"] * "]", pad_intent))
            end
            write(io, "  ", rpad(arg["name"], pad_name) , "  ", arg["doc"], "\n")
        end
    end

    # doxygen warning
    if haskey(fct_spec, "warning")
        println(io, " *")
        println(io, " * @warning ", fct_spec["warning"])
    end

    # doxygen reference
    if haskey(fct_spec, "see")
        println(io, " *")
        println(io, " * @see ", "trixi_", fct_spec["see"], "_api_c")
    end

    # doxygen return
    if haskey(fct_spec, "return") && haskey(fct_spec["return"], "doc")
        println(io, " *")
        println(io, " * @return ", fct_spec["return"]["doc"])
    end

    # doxygen end
    println(io, " */")

    # signature
    write_signature_c(io, fct_spec)
    write(io, " {\n\n")

    # content
    short_name = chopprefix(fct_spec["name"], "trixi_")
    println(io, "    // Get function pointer")
    println(io, "    ", fct_spec["return"]["ctype"],
                " (*", short_name, ")(int) = ",
                "trixi_function_pointers[", enum_name(fct_spec["name"]), "];\n")
    println(io, "    // Call function")
    println(io, "    return ", short_name, "(handle);")
    println(io, "}\n\n")
end


function write_api_f90(io, fct_spec)

    # doxygen header
    println(io, "!>")
    println(io, "!! @anchor ", fct_spec["name"], "_api_c" )
    println(io, "!!")
    println(io, "!! @brief ", fct_spec["doc_brief"])
    println(io, "!!")

    # doxygen detailed doc
    if haskey(fct_spec, "doc_detail")
        TextWrap.println_wrapped(io, fct_spec["doc_detail"], width=linewidth,
                                 initial_indent = "!! ", subsequent_indent = "!! ")
    end
    println(io, "!!")

    # doxygen parameters
    if haskey(fct_spec, "args")
        pad_name = maxlength("name", fct_spec["args"])
        pad_intent = maxlength("intent", fct_spec["args"]) + 2
        for arg in fct_spec["args"]
            write(io, "!! @param")
            if haskey(arg, "intent")
                write(io, rpad("[" * arg["intent"] * "]", pad_intent))
            end
            write(io, "  ", rpad(arg["name"], pad_name) , "  ", arg["doc"], "\n")
        end
    end

    # doxygen return
    if haskey(fct_spec, "return") && haskey(fct_spec["return"], "doc")
        println(io, "!!")
        println(io, "!! @return  ", fct_spec["return"]["doc"])
    end

    # TODO
    # @see @ref trixi_nelements_api_c "trixi_nelements (C API)"

    # signature
    write_signature_f90(io, fct_spec)
end


function write_libtrixi_jl(io, fct_spec)
    println(io, "export ", fct_spec["name"], ",")
    println(io, "       ", fct_spec["name"], "_cfptr,")
    println(io, "       ", fct_spec["name"], "_jl")
end


function write_api_c_jl(io, fct_spec)
    # docstring
    println(io, "\"\"\"")
    write(io, "    ", fct_spec["name"], "(simstate_handle::Cint)::")
    if haskey(fct_spec, "return")
        return_type = julia_ctype[fct_spec["return"]["ctype"]]
    else
        return_type = "Cvoid"
    end
    write(io, return_type, "\n\n")
    println(io, fct_spec["doc_brief"])
    println(io, "\"\"\"")

    # forward declaration
    println(io, "function ", fct_spec["name"], " end\n")

    # ccallable
    println(io, "Base.@ccallable function ", fct_spec["name"],
                "(simstate_handle::Cint)::", return_type)
    println(io, "    simstate = load_simstate(simstate_handle)")
    if haskey(fct_spec, "return")
        println(io, "    return ", fct_spec["name"], "_jl(simstate)")
    else
        println(io, fct_spec["name"], "_jl(simstate)")
        println(io, "    return nothing")
    end
    println(io, "end\n")
    println(io, fct_spec["name"], "_cfptr() = @cfunction(", fct_spec["name"], ", ", return_type, ", (Cint,))\n\n")
end


function write_api_jl_jl(io, fct_spec)
    println(io, "function ", fct_spec["name"], "_jl(simstate)")
    println(io, "")
    println(io, "    # TODO: write nice Julia-code here")
    println(io, "")
    println(io, "end\n\n")
end




# check argument
if length(ARGS) < 1
    error("ERROR: missing argument TARGET_DIR/YAML_SPEC.yaml")
end

target_directory = dirname(ARGS[1])
spec = YAML.load_file(ARGS[1])


# create directories
#mkdir(joinpath(target_directory, "LibTrixi.jl"))
#mkdir(joinpath(target_directory, "LibTrixi.jl/src"))
#mkdir(joinpath(target_directory, "src"))


# open files
api_c   =     open(joinpath(target_directory, "src/api.c"),   "w")
trixi_h =     open(joinpath(target_directory, "src/trixi.h"), "w")
api_f90 =     open(joinpath(target_directory, "src/api.f90"), "w")
libtrixi_jl = open(joinpath(target_directory, "LibTrixi.jl/src/LibTrixi.jl"), "w")
api_c_jl =    open(joinpath(target_directory, "LibTrixi.jl/src/api_c.jl"), "w")
api_jl_jl =   open(joinpath(target_directory, "LibTrixi.jl/src/api_jl.jl"), "w")


# prepend trixi_ to every function name
for fct in spec["functions"]
    if !startswith(fct["name"], "trixi_")
        fct["name"] = "trixi_" * fct["name"]
    end
end


# generate and write function pointer names
println(api_c, "    /* TODO: add to function pointer enums */\n")
for fct in spec["functions"]
    write_fptr_enum(api_c, fct)
end
println(api_c, "")
for fct in spec["functions"]
    write_fptr_name(api_c, fct)
end
println(api_c, "\n")


# write source files
for fct in spec["functions"]
    write_trixi_h(trixi_h, fct)
    write_api_c(api_c, fct)
    write_api_f90(api_f90, fct)
    write_libtrixi_jl(libtrixi_jl, fct)
    write_api_c_jl(api_c_jl, fct)
    write_api_jl_jl(api_jl_jl, fct)
end


# close
close(trixi_h)
close(api_c)
close(api_f90)
close(libtrixi_jl)
close(api_c_jl)
close(api_jl_jl)
