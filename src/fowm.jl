using Plots,DifferentialEquations


function FOWM(du,u,p,t)
    
    # States
    m_ga,m_gt,m_lt,m_gb,m_gr,m_lr = u
    # Parameters
    ρ_l,P_r,P_s,α_gw,ρ_mres,M,T,Lᵣ,L_fl,L_t,L_a,H_t,
    H_pdg,H_vgl,D_ss,D_t,D_a,m_still,C_g,C_out,V_eb,E,K_w,K_a,K_r,ω = p

    W_iv   = 
    W_r    =
    W_whg  =
    W_whl  =
    W_gc   =
    W_g    =
    W_gout =
    W_lout = 

    du[1] = δm_ga = W_gc - W_iv
    du[2] = δm_gt = W_r*α_gw+W_iv-W_whg
    du[3] = δm_lt = W_r*(1-α_gw) - W_whl
    du[4] = δm_gb = (1-E)*W_whg - W_g
    du[5] = δm_gr = E*W_whg + W_g - W_gout
    du[6] = δm_lr = W_whl - W_lout
end
