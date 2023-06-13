module LibTrixi

export trixi_initialize, trixi_finalize, trixi_get_timestep, trixi_integrate,
       trixi_eval_string

Base.@ccallable function trixi_initialize(comm::Cint)::Cvoid
    # Init Trixi
    return nothing
end
trixi_initialize_c() = @cfunction(trixi_initialize, Cvoid, (Cint,))

Base.@ccallable function trixi_finalize()::Cvoid
    # Finalize Trixi
    return nothing
end
trixi_finalize_c() = @cfunction(trixi_finalize, Cvoid, ())

Base.@ccallable function trixi_get_timestep()::Cdouble
    # Return time step size
    return 1.0
end
trixi_get_timestep_c() = @cfunction(trixi_get_timestep, Cdouble, ())

Base.@ccallable function trixi_integrate()::Cvoid
    # Integrate in time for one time step
    return nothing
end
trixi_integrate_c() = @cfunction(trixi_integrate, Cvoid, ())

Base.@ccallable function trixi_eval_string(code::Cstring)::Cvoid
    # Integrate in time for one time step
    return nothing
end
trixi_eval_string_c() = @cfunction(trixi_eval_string, Cvoid, (Cstring,))

end # module LibTrixi
