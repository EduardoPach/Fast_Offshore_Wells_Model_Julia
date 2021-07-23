using Plots,DifferentialEquations
#=
Objective: This script intends to reproduce the Fast Offshore Wells Model.
Paper: Fast Offshore Wells Model (FOWM): A practical dynamic model for multiphase oil production systems in deepwater and ultra-deepwater scenarios
Authors: Fabio C.Diehl Thiago K.Anzai Cristina S.Almeida Oscar F.Von Meien Saul S.Neto Vinicius R.Rosa Mario C.M.M.Campos Filipe Reolon Giovani Gerevini Cassiano Ranza MarceloFarenzena Jorge O.Trierweiler
=#

function fowm(du,u,p,t)    
    #= 
    States: 
        01 - m_ga:      Gas Annular 
        02 - m_gt:      Gas Tubing 
        03 - m_lt:      Liq Tubing 
        04 - m_gb:      Gas Bubble
        05 - m_gr:      Gas Flowline 
        06 - m_lr:      Liq Flowline
    =#
    m_ga,m_gt,m_lt,m_gb,m_gr,m_lr = u
    #= 
    Parameters:
    - Operation Parameter:
        01 - z: Choke Valve Opening Fraction
    - Well Parameters
        01 - ρ_l:       Liquid Density
        02 - P_r:       Reservoir's Pressure
        03 - P_s:       After Choke Pressure
        04 - α_gw:      Gas Mass Fraction at Reservoir's Condition
        05 - ρ_mres:    Reservoir's Density
        06 - M:         Gas Molecular Weight
        07 - T:         Average Temperature
        08 - L_r:       Riser Length
        09 - L_fl:      Flowline Length
        10 - L_t:       Tubing Length
        11 - L_a:       Annular Length
        12 - H_t:       Distance Xmas Tree - Bottom Hole
        13 - H_pdg:     Distance Xmas Tree - PDG Point
        14 - H_vgl:     Distance Xmas Tree - Gas Lift Injection Point
        15 - D_ss:      Subsea Pipeline Diameter
        16 - D_t:       Tubing Diameter
        17 - D_a:       Annular Diameter
        18 - θ:         Annular Diameter
    - Estimated Parameters in Diehl et al.
        01 - m_still:   Minimum Liquid Mass at Subsea Pipeline
        02 - C_g:       Virtual Valve Flow Constant
        03 - C_out:     Choke Valve Flow Constant
        04 - V_eb:      Bubble Volume
        05 - E:         Mass Fraction of Gas Bypassing Virtual Valve
        06 - K_w:       Xmas Tree Flow Constant
        07 - K_a:       Annular-Tubing Flow Constant
        08 - K_r:       Reservoir's Flow Constant
        09 - ωᵤ:        Bubble Location (Assistant Parameter)
    =#
    z,ρ_l,P_r,P_s,α_gw,ρ_mres,M,T,L_r,L_fl,L_t,L_a,H_t,
    H_pdg,H_vgl,D_ss,D_t,D_a,θ,m_still,C_g,C_out,V_eb,E,K_w,K_a,K_r,ωᵤ = p

    # Universal Gas Constant
    R      = 8314 # J/kmolK
    g      = 9.81     
    #=
    First Rank Variables:
        01 - V_t:       Tubing Volume
        02 - V_ss:      Bubble Downstream Volume  
        03 - V_a:       Annular Volume
        04 - A_ss:      Subsea Pipeline Cross Sectional Area
        05 - V_gt:      Tubing Gas Volume
        06 - ρ_mt:      Mixture Density
        07 - ρ_gt:      Gas Density
    =#
    V_t    = π*D_t^2/4*L_t
    V_ss   = π*D_ss^2/4*L_r + π*D_ss^2/4*L_fl
    V_a    = π*D_a^2/4*L_a
    A_ss   = π*D_ss^2/4
    V_gt   = V_t - m_lt/ρ_l
    ρ_mt   = (m_gt+m_lt)/V_t
    ρ_gt   = m_gt/V_gt
    #=
    Second Rank Variables:
        01 - P_ai:      Annular Gas Injection Point Pressure        
        02 - P_tt:      Tubing's Topside Pressure
        03 - P_tb:      Tubing Gas Injection Point Pressure
        04 - P_pdg:     Pressure at PDG Point
        05 - P_bh:      Pressure at Bottom Hole
        06 - P_rt:      Pressure at the Riser's Topside
        07 - P_rb:      Pressure before the Bubble      
        08 - P_eb:      Bubble Pressure         
        09 - ρ_ai:      Gas Density at Annular
        10 - α_gt:      Gas Mass Fraction at Tubing
        11 - α_gr:      Gas Mass Fraction at Subsea Pipeline
        12 - α_lr:      Liquid Mass Fraction at Subsea Pipeline

    =#
    P_ai   = m_ga*(R*T/V_a/M+g*L_a/V_a)
    P_tt   = ρ_gt*R*T/M
    P_tb   = P_tt + ρ_mt*g*H_vgl
    P_pdg  = P_tb +ρ_mres*g*(H_pdg-H_vgl)
    P_bh   = P_pdg + ρ_mres*g*(H_t-H_pdg)
    P_rt   = m_gr*R*T/M/(ωᵤ*V_ss-(m_lr+m_still)/ρ_l)
    P_rb   = P_rt + (m_lr+m_still)*g*sin(θ)/A_ss
    P_eb   = m_gb*R*T/M/V_eb
    ρ_ai   = M*P_ai/R/T
    α_gt   = m_gt/(m_gt+m_lt)
    α_gr   = m_gr/(m_gr+m_lr)
    α_lr   = 1-α_gr
    #=
    Mass Flow Rates:
        01 - W_iv:      Gas Annular to tubing
        02 - W_r:       Reservoir to Bottom Hole
        03 - W_whg:     Gas at Xmas Tree
        04 - W_whl:     Liquid at Xmas Tree
        05 - W_gc:      Gas Annular
        06 - W_g:       Gas at Virtual Valve
        07 - W_gout:    Gas through Choke
        08 - W_lout:    Liquid through Choke
    =#
    W_iv   = K_a*√(ρ_ai*max(0,P_ai-P_tb)) 
    W_r    = K_r*(1 - 0.2*P_bh/P_r-(0.8*P_bh/P_r)^2)
    W_whg  = K_w*α_gt*√(ρ_l*max(0,P_tt-P_rb))
    W_whl  = K_w*(1-α_gt)*√(ρ_l*max(0,P_tt-P_rb))
    W_gc   = W_iv
    W_g    = max(0,C_g*(P_eb-P_rb))
    W_gout = α_gr*C_out*z*√(ρ_l*max(0,P_rt-P_s))
    W_lout = α_lr*C_out*z*√(ρ_l*max(0,P_rt-P_s))
    # States' Derivative 
    du[1]  = δm_ga = W_gc - W_iv
    du[2]  = δm_gt = W_r*α_gw+W_iv-W_whg
    du[3]  = δm_lt = W_r*(1-α_gw) - W_whl
    du[4]  = δm_gb = (1-E)*W_whg - W_g
    du[5]  = δm_gr = E*W_whg + W_g - W_gout
    du[6]  = δm_lr = W_whl - W_lout
end

function simulate_fowm(u₀,tf,z,Δt=[])
    #=
    Args:
        - u₀: Initial Condition
        - tf: Final Simulation Time (hours)
        - z:  Choke Valve Opening Fraction
        - Δt: Time Step to Save Results (hours)
    =#
    tspan = (0,tf*3600)
    p = [z,ρ_l,P_r,P_s,α_gw,ρ_mres,M,T,L_r,L_fl,L_t,L_a,H_t,H_pdg,H_vgl,D_ss,D_t,D_a,θ,m_still,C_g,C_out,V_eb,E,K_w,K_a,K_r,ωᵤ]
    prob = ODEProblem(fowm,u₀,tspan,p)
    sol = solve(prob,Tsit5(),saveat = Δt)
    return sol
end

# Parameters for Simulation (Diehl et al. Table 2 Well A and Table 3 Real Well A)
ρ_l         =   900.0   
P_r         =   225e5
P_s         =   10e5
α_gw        =   0.0188
ρ_mres      =   892.0
M           =   18.0
T           =   298.0
L_r         =   1569.0
L_fl        =   2928.0
L_t         =   1639.0
L_a         =   1118.0
H_t         =   1279.0
H_pdg       =   1117.0
H_vgl       =   916.0
D_ss        =   0.15
D_t         =   0.15
D_a         =   0.14
θ           =   π*60/180
m_still     =   6.222e1
C_g         =   1.137e-3
C_out       =   2.039e-3
V_eb        =   6.098e1
E           =   1.545e-1
K_w         =   6.876e-4
K_a         =   2.293e-5
K_r         =   1.269e2
ωᵤ          =   2.780e0

# Initial Conditions
x₀ = repeat([1000.0],6)
# Simulation Time and Time-step in Hours
tf = 30.0
Δt = 1/60*15*3600
# Choke Opening Fraction
z = 0.2
# Simulating
sol = simulate_fowm(x₀,tf,z,Δt)