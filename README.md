Ejemplo de SA para TSP de 10 ciudades

En el archivo cost_matrix.txt está la matriz de costos (10x10) y el archivo randoms.txt tiene una lista de 1.000 números aleatorios previamente calculados.

Representación:
Cada X_i representa una ciudad                  
[X1-X2-X3-X4-X5-X6-X7-X8-X9-X10]                    
y cada par contiguo representa la dupla {ciudad_origen-ciudad_destino}                  
                                        
Movimiento:
SWAP entre elementos contiguos, intercambiando el elemento de la izquierda hacia la derecha y viceversa. No se realiza movimiento en X10.
                    
Ejemplo:
X2-X1-X3-X4-X5-X6-X7-X8-X9-X10
X1-X3-X2-X4-X5-X6-X7-X8-X9-X10
X1-X2-X4-X3-X5-X6-X7-X8-X9-X10