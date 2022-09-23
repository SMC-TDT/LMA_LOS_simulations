# LMA Line Of Sight simulations
Aquest programari en llenguatge R estima, a partir d'un model digital de terreny (DEM), la altura mínima de visibilitat d'una estació LMA (en unes coordenades donades per l'usuari) en cada punt del territori català.

## DESCRIPCIÓ



### Estructura de carpetes:

La carpeta LMA_LOS_simulations ha de contenir 2 carpetes:
- DATA: 
- scripts: conté els scripts necessaris per a la configuració i execució de l’algorisme (*LMA_LOS_simulations.R*, *LMA_sim_funs.R* i *LMA_SIM_sets.R*).

### Llibreries R:
- raster
- gdal
- plyr
- data.table
- akima
- maptools

## INSTRUCCIONS D'ÚS

1. Copieu els arxius RAW comprimits del període desitjat (XXXRAWYYYYMMDD.tgz) a la carpeta *~/RAW2GRID/RAW/*.

  `$ cp CDVRAW20210724.tgz ~/RAW2GRID/RAW`
