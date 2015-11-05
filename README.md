# Space Invaders MIPS Assembly
Juego de Space Invaders hecho en MIPS Assembly para el programa MARS.

## Preview
![alt tag](https://github.com/Ricardo96r/Space-Invaders-MIPS/blob/master/imagen.png)

## Instrucciones
### Para jugarlo primero: 
- Abrir MARS
- Tools -> Bitmap Display
- unit width in pixel: 16 / unit height in pixel: 16
- Display Width in Pixels: 512 / Display Height in Pixels: 512
- Base address for display: $gp
- Tools -> Keyboard and Display
- Connect to MIPS
- Assemble y RUN

### Información:
 - Se mueve hacia la  izquierda con "a" minuscula!
 - Se mueve hacia la derecha con "d" minuscula!
 - Se dispara con la tecla espacio
 - Se tiene que jugar con letras minusculas (bloq mayús desactivado)
 - Los pixeles azules son el nivel actual (1, 2 o 3)
 - Los Pixeles rosados son las vidas restantes

NOTA: Los popups de MARS SYSCALL(50-55) aveces dan error y se quedan en blanco,
por lo cual hay que cerrar el MARS y volverlo a abrir. Este error es culpa de MARS.

NOTA: El archivo macro.asm tiene que estar en la misma carpeta que este archivo.

## Gracias a
WEB: https://dtconfect.wordpress.com/projects/year2/mips-snake-and-primlib/
