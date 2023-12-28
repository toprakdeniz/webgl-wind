Thanks to Volodymyr Agafonkin and everyone who inspires him.

### Purpose of this fork

The basic animation represents a fixed time of wind data. A good idea is to have the time it represents continue as the animation continues. I think it can be done with 2 vector field textures in the update program. We calculate the particle vector by mixing the vectors of two vector fields according to the ratio of the time elapsed between the two representations at that point.

It will be fun to create a tensor imitation on webgl. 

### Plan of attack

* [-] Update the update vertex source file to use two textures as vector fields, u_wind1, u_wind2 and, add u_elapsed_time to control mix function.  

* [-] Create a tensor imitator that automatically changes u_wind1 and u_wind2 as time passes. 

* [-] Connect pieces. 

### Running the demo locally

```bash
npm install
npm run build
npm start
# open http://127.0.0.1:1337/demo/
```

### Downloading weather data

1. Install [ecCodes](https://confluence.ecmwf.int//display/ECC/ecCodes+Home) (e.g. `brew install eccodes`).
2. Edit constants in `data/download.sh` for desired date, time and resolution.
3. Run `./data/download.sh <dir>` to generate wind data files (`png` and `json`) for use with the library.
