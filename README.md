# Fast Offshore Wells Model (FOWM)

In this repo the FOWM, from [Diehl et al., 2017](https://www.sciencedirect.com/science/article/abs/pii/S0098135417300443), will be replicated using Julia Programming Language.

## System Representation
Here is a representation of the system available in the work of [Diehl et al., 2017](https://www.sciencedirect.com/science/article/abs/pii/S0098135417300443)

![](images/representation.jpg)

## Model

$$\dfrac{dm_{ga}}{dt} = W_{gc} - W_{iV}$$ (1)
$$\dfrac{dm_{gt}}{dt} = W_r\alpha_{gw} + W_{iV}-W_{whg}$$ (2)
$$\dfrac{dm_{lt}}{dt} = W_r(1-\alpha_{gw}) - W_{whl}$$ (3)
$$\dfrac{dm_{gb}}{dt} = (1-E)W_{whg}-W_g$$ (4)
$$\dfrac{dm_{gr}}{dt} = EW_{whg}+W_g-W_{gout}$$ (5)
$$\dfrac{dm_{lr}}{dt} = W_{whl}-W_{lout}$$ (6)
<br>
<br>


Where:

|   Variables   |                        Description                        |
| :-----------: | :-------------------------------------------------------: |
|   $m_{ga}$    |                 Gas mass in the annualar                  |
|   $m_{gt}$    |                  Gas mass in the tubbing                  |
|   $m_{lt}$    |                  Liq mass in the tubing                   |
|   $m_{gb}$    |                  Gas mass in the bubble                   |
|   $m_{gr}$    |                 Gas mass in the flowline                  |
|   $m_{lr}$    |                Liquid mass in the flowline                |
|   $W_{iV}$    |           Gas mass flow from annular to tubing            |
|    $W_{r}$    |          Reservoir to the bottom hole mass flow           |
|   $W_{whg}$   |                Gas mass flow at Xmas Tree                 |
|   $W_{whl}$   |                Liq mass flow at Xmas Tree                 |
|   $W_{gc}$    |            Gas lift mass flow entering annular            |
|    $W_{g}$    |            Gas mass flow at the virtual valve             |
|  $W_{gout}$   |        Gas mass flow through topside valve (Choke)        |
|  $W_{lout}$   |        Gas mass flow through topside valve (Choke)        |
|      $E$      |         Mass fraction of gas bypassing the bubble         |
| $\alpha_{gw}$ | Gas mass fraction at resorvoir's pressure and temperature |


<br>
<br>

Where:

$$W_{iV} = K_a\sqrt{\rho_{ai}(P_{ai}-P_{tb})}$$ (7)
$$W_{r} = K_r \left [1 - 0.2\dfrac{P_{bh}}{P_{r}} - \left(0.8\dfrac{P_{bh}}{P_r}\right)^2 \right]$$ (8)
$$W_{whg} = K_w\sqrt{\rho_{L}(P_{tt}-P_{rb})}\alpha_{gt}$$ (9)
$$W_{whl} = K_w\sqrt{\rho_{L}(P_{tt}-P_{rb})}(1-\alpha_{gt})$$ (10)
$$W_{g} = C_g(P_{eb} - P_{rb}) $$ (11)
$$W_{gout} = \alpha_g C_{out} z  \sqrt{\rho_L(P_{rt}-P_{s})}$$ (12)
$$W_{lout} = \alpha_l C_{out} z  \sqrt{\rho_L(P_{rt}-P_{s})}$$ (13)




