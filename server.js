const express = require('express')
const bodyParser = require('body-parser')
const app = express()

// server code //
__dirname= 'dist/hw82';
app.use(express.static(__dirname))
// end ///
app.use(bodyParser.json())

app.use(bodyParser.urlencoded({extended: true}) );

const request = require('request');

google_api_key = "AIzaSyByVe_oKFDcxgoi_USkqNkurU28eilrz3A";
darksky_api_key = "89b9849303b7b90094b011d8ebd2489d";
search_engine_id = "001678684831762734266:ccboqbsjrkv";

app.all("/*", function(req, res, next){
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, Content-Length, X-Requested-With');
    next();
});

app.route('/api/cats:name').get((req,res)=>{
    console.log('get city')
    const requestedCatName = req.params['name']
    const url = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input="+requestedCatName+"&types=(cities)&language=en&key="+google_api_key;
    request(url, { json: true }, (err, res2, body) => {
        if (err) { res.send([]); return; }
        console.log('body:',body);
        if (body.predictions.length == 0) { res.send([]); return;}
        packet = []
        for( pred in body.predictions){
            pred = parseInt(pred,10)
            if(pred == 5) break;
            packet.push(body.predictions[pred].description)
        }
        res.send(packet)
      });
})
function geocodeAddress(STREET, CITY, STATE, callback,error){
const url = "https://maps.googleapis.com/maps/api/geocode/json?address="+STREET+","+CITY+","+STATE+"&key="+google_api_key;
  coordinates = {}
  request(url, { json: true }, (err, res2, body) => {
    if (err) { res.send([]); return; }
    console.log('body:',body);
    if(body.status == 'ZERO_RESULTS'){callback(null)}
    coordinates = body.results[0].geometry.location
    callback(coordinates); 
  });
}
function getCity(coordinates,callback){
    if(coordinates == null){callback(null)}
    var address = coordinates['lat']+','+coordinates['lng'];
    var url = "https://maps.googleapis.com/maps/api/geocode/json?latlng="+address+"&key="+google_api_key
    ;
    request(url, { json: true }, (err, res2, body) => {
        if (err) { callback([]); return; }
        console.log('body:',body);
        callback(body.city)
    });
}
function getForcast(coordinates,callback){
    if(coordinates == null){callback(null)}
    var address = coordinates['lat']+', '+coordinates['lng'];
    var url = "https://api.darksky.net/forecast/"+darksky_api_key+"/"+address;
    request(url, { json: true }, (err, res2, body) => {
        if (err) { callback([]); return; }
        console.log('body:',body);
        var currently = {}
        currently['Timezone'] = body["timezone"];
        currently['Temperature'] = Math.round(body["currently"]["temperature"]);
        currently['Summary'] = body["currently"]["summary"];
        currently['Humidity'] = Math.round(body["currently"]["humidity"]*100);
        currently['Pressure'] = parseFloat(body["currently"]["pressure"]).toFixed(2);
        currently['WindSpeed'] = parseFloat(body["currently"]["windSpeed"]).toFixed(2);
        currently['Visibility'] = parseFloat(body["currently"]["visibility"]).toFixed(2);
        currently['CloudCover'] = Math.round(body["currently"]["cloudCover"]*100);
        currently['Ozone'] = parseFloat(body["currently"]["ozone"]).toFixed(2);
        currently['Icon'] = body["currently"]["icon"];
        currently['Precipitation'] = Math.round(body["currently"]["precipIntensity"]).toFixed(2);


        var hourly = {"temperature":[], "pressure":[], "humidity":[], "ozone":[], "visibility":[], "windSpeed":[]}
        for(var i = 0; i < body.hourly.data.length; ++i){
            if(i == 24) break;
            hourly.temperature.push(Math.round(body.hourly.data[i].temperature));
            hourly.pressure.push(parseFloat(body.hourly.data[i].pressure).toFixed(2));
            hourly.humidity.push(Math.round(body.hourly.data[i].humidity*100));
            hourly.ozone.push(parseFloat(body.hourly.data[i].ozone).toFixed(2));
            hourly.visibility.push(parseFloat(body.hourly.data[i].visibility).toFixed(2));
            hourly.windSpeed.push(parseFloat(body.hourly.data[i].windSpeed).toFixed(2));
        }
        var weekly = {"time":[], "temperature":[],"sunrise":[],"sunset":[],"icon":[],"summary":[]}
        for(var i = 0; i < body.daily.data.length; ++i){
            if(i == 8) break;
            weekly.time.push(body.daily.data[i].time);
            weekly.temperature.push([Math.round(body.daily.data[i].temperatureLow),Math.round(body.daily.data[i].temperatureHigh)]);
            weekly.sunrise.push(body["daily"]["data"][i]['sunriseTime']);
            weekly.sunset.push(body["daily"]["data"][i]['sunsetTime']);
            weekly.icon.push(body["daily"]["data"][i]['icon']);
            weekly.summary.push(body["daily"]["data"][i]['summary']);
        }
        callback({"currently":currently,"hourly":hourly,"weekly":weekly})
    });
}
function getImages(CITY,callback){
   var  url = "https://www.googleapis.com/customsearch/v1?q="+CITY+"&cx="+search_engine_id+"&imgSize=huge&num=8&searchType=image&key="+google_api_key;
    request(url, { json: true }, (err, res2, body) => {
        if (err) { callback([]); return; }
        console.log('body:',body);
        var images = []
        for(i=0;i<body.items.length;i++){
            images.push(body.items[i].link)
        }
        callback({"images":images})
    });
}
app.route('/api/cats').post((req, res) => {
  console.log('get weather');
  const STREET = req.body['street']
  const CITY = req.body['city']
  const STATE = req.body['state'] 
  var packet = {}
  var coordinates ={}
  geocodeAddress(STREET, CITY, STATE,function(data){
    coordinates = data
    if(coordinates == null){res.send(null); return;}
    getForcast(data,function(data2){
        packet = data2
        getImages(CITY,function(data3){
            packet.images = data3.images;
            packet.weekly.coord = coordinates
            res.send(packet);
        })
    });
  });
})

app.route('/api/cats/cl').post((req, res) => {
    console.log('get current weather');
    var packet = {}
    var coordinates ={'lat':req.body.lat,'lng':req.body.lng}
    var CITY = req.body.city
    getForcast(coordinates,function(data2){
        getImages(CITY,function(data3){
            packet = data2
            packet.images = data3.images
            packet.weekly.coord = coordinates
            res.send(packet);

        })
    })
  })

function formatDate(nowDate) {
    nowDate = new Date(nowDate*1000)
    return nowDate.getDate() +"/"+ (nowDate.getMonth() + 1) + '/'+ nowDate.getFullYear();
  }

function getWeatherWithTime(lat,lng,time,callback){
    var url = 'https://api.darksky.net/forecast/'+darksky_api_key+'/'+lat+','+lng+','+time;
    request(url, { json: true }, (err, res2, body) => {
        if (err) { callback([]); return; }
        console.log('body:',body);
        data = {}
        data.date = formatDate(body.daily.data[0].time);
        data.temperature = body.currently.temperature;
        data.summary = body.currently.summary;
        data.icon = body.currently.icon
        data.precipitation = parseFloat(body.currently.precipIntensity).toFixed(2);
        data.chanceOfRain = parseFloat(body.currently.precipProbability*100).toFixed(2);
        data.windSpeed = parseFloat(body.currently.windSpeed).toFixed(2);
        data.humidity = Math.round(body.currently.humidity*100).toFixed(2);
        data.visibility = body.currently.visibility
        callback(data)
    });
    
}

app.route('/api/cats/time').post((req, res) => {
    console.log('get weather at time');
    const LAT = req.body['coord']['lat']
    const LNG = req.body['coord']['lng']
    const TIME = req.body['time']
    getWeatherWithTime(LAT,LNG,TIME,function(data){
        res.send(data);
    });

})

process.on('uncaughtException', function (err) {
    console.log(err);
});

app.listen(3000,()=>{
    console.log('Server started!')
})
/*
// server code //
app.listen(process.env.PORT,()=>{
    console.log('Server started!')
})
*/
// end //