package ;

import js.node.Http;
import js.Node.console;
import js.Node.*;

import js.node.Fs;
import js.node.Url;

/**
 * @author Matthijs Kamstra aka [mck]
 */
@:expose
class JsonDB{

	// defaults
	private var filename = 'database.json';
	private var humanReadable = true;
	private var autosave = true;
	private var serverdata = {};

	var DB_FILE = 'database.json';
	var PORT = 4000;

	/**
	 *  json database for small projects
	 *
	 *  @param dbName 				- name of the database
	 *  @param isHumanReadable 		- use a readable json db
	 *  @param isAutoSave 			- save upon changes
	 */
	public function new (?dbName:String, ?isHumanReadable:Bool = true , ?isAutoSave:Bool = true){
		// check for .json at the end of the file
		if(dbName != null && dbName.indexOf('.json') == -1){
			dbName += '.json';
		}
		if(dbName != null ) DB_FILE = dbName;

		this.humanReadable = isHumanReadable;
		this.autosave = isAutoSave;

		init();
	}

	private function init(){
		//create file if it's present.
		//synchronous because it needs to happen before requests can be processed
		try	{
			if(Fs.statSync(DB_FILE).isFile() ){
				// trace('database "${DB_FILE}" exist');
				this.serverdata = readFromFile();
			}
		} catch (e:Dynamic){
			// trace('database "${DB_FILE}" doesn\'t exist, create');
			writeToFile(this.serverdata);
		}
		// Warning : Use Fs.statSync or Fs.accessSync instead.
		// if(!Fs.statSync(DB_FILE).isFile()){
		// 	console.log('Initialising storage.\n -Creating ${DB_FILE} file');
		// 	Fs.writeFileSync(DB_FILE,"{}");
		// }
	}

	/**
	 *  set a key into the database, it will overwrite existing value
	 *
	 *  @example 			db.set('test2', [1,2,3]);
	 *
	 *  @param key 			key value used in DB
	 *  @param value 		can be a string, a number/float/int, an object (JSON object), an array, a boolean, null
	 *  @return Dynamic		the db
	 */
	public function set(key:String, value:Dynamic):Dynamic{
		Reflect.setField(serverdata, key, value);
		if (this.autosave) writeToFile(serverdata);
		return serverdata;
	}
	private function _set(data:Dynamic, key:String, value:Dynamic):Dynamic{
		Reflect.setField(data, key, value);
		if (this.autosave) writeToFile(data);
		return data;
	}

	/**
	 *  get a key value from the database
	 *
	 *  @example 			var val = db.get('test2');
	 *
	 *  @param key 			key value used in DB
	 *  @return Dynamic		what every value is stored in the key
	 */
	public function get(key:String):Dynamic{
		return Reflect.getProperty(serverdata, key);
	}
	private function _get(data:Dynamic, key:String):Dynamic{
		return Reflect.getProperty(data, key);
	}

	/**
	 *  check if a key value is in the database
	 *
	 *  @example 			if (db.has('test2')){ // do something};
	 *
	 *  @param key 			key value used in DB
	 *  @return Bool		does it exist or not
	 */
	public function has(key:String):Bool{
		return Reflect.hasField(serverdata, key);
	}
	private function _has(data:Dynamic, key:String):Bool{
		return Reflect.hasField(data, key);
	}

	/**
	 *  remove a key value from the database
	 *
	 *  @example 			db.delete('test2');
	 *
	 *  @param key 			key value used in DB
	 */
	public function delete(key:String){
		Reflect.deleteField(serverdata, key);
		if (this.autosave) writeToFile(serverdata);
	}

	/**
	 *  the key will be an array, value will be pushed into array
	 *
	 *  @example 			db.push('arr0', {date: Date.now()});
	 *						db.push('arr1' , [1,2,3,4]);
	 *						db.push('arr2' , true);
	 *						db.push('arr3' , 'foo');
	 *
	 *  @param key 			key value used in DB
	 *  @param value 		can be a string, a number/float/int, an object (JSON object), an array, a boolean, null
	 */
	public function push(key:String, value:Dynamic){
		// remove empty path '/aap/'
		var pathArray = key.split('/');
		var storeArray = [];



// 		var test = Reflect.getProperty(serverdata, key.split('/').join('.'));
// 		trace(test);


// 		trace(Reflect.getProperty(serverdata, 'zero.one.two.threes'));
// 		trace(Reflect.getProperty(serverdata, 'zero/one/two/threes'));


// return;

		// [mck] currently overwrites
		if(pathArray.length > 1){
			var obj = serverdata;
			for (i in 0...pathArray.length){
				trace(i == pathArray.length-1);
				var _pathArray = pathArray[i];
				if (_has(obj, _pathArray)){
					trace('yes, key: "${_pathArray}" exists');
					obj = _get(obj, _pathArray);


				} else {
					trace('no, key: "${_pathArray}" doesn\'t exists');
					// obj = _set(obj, _pathArray, {});
					// obj = obj;
				}
				// try{
				// 	trace(obj.length());
				// } catch(e:Dynamic){
					trace(obj);
				// }
			}

			// var tt = new Array();
			// 	trace(tt.push(obj));
			// 	trace('tt = '+tt);
			// var tt:Array<Dynamic> = obj;
			// tt.push(value);
			// new Array(obj).push

			// return ;


			// there is an path!
			var test = [];
			test.push(value);

			var parentObj = {};
			Reflect.setField(parentObj, pathArray[pathArray.length-1], test);
			for (i in 1...pathArray.length -1){
				// trace('parentObj: '+parentObj);
				var obj2={};
				Reflect.setField(obj2, pathArray[(pathArray.length - 1) - i], parentObj);
				// trace('obj2: '+obj2);
				parentObj = obj2;
			}

			set(pathArray[0], parentObj);
			return;
			trace(parentObj);
		}


		if(Reflect.hasField(serverdata, key) ){
			// trace('key exists');
			storeArray = Reflect.getProperty(serverdata, key);
		// } else {
			// trace('key DOESNT exists');
			// storeArray.push(value);
			// Reflect.setField(serverdata, key, storeArray);
		}
		storeArray.push(value);
		set(key, storeArray);
	}

	/**
	 *  return the json data use as database
	 *
	 *  @return Dynamic		the db
	 */
	public function getData():Dynamic{
		return this.serverdata;
	}

	/**
	 *  use an object to save into DB
	 *
	 *  @example 		db.setData({test:1, foo:2});
	 *  @param data 	an object to store in database
	 */
	public function setData(data:Dynamic) {
		// trace('setData: data: ' + data);
		for( ff in Reflect.fields(data) ){
			// will overwrite data
			Reflect.setField (this.serverdata, ff, Reflect.field(data, ff));
		}
		// parse object to json string
		writeToFile(haxe.Json.parse(haxe.Json.stringify(this.serverdata)));
	}


	// ____________________________________ private ____________________________________


	private function readFromFile() : String {
		return haxe.Json.parse(Fs.readFileSync(DB_FILE, "utf8"));
	}

	private function writeToFile(data:Dynamic) {
		// trace('writeToFile(${data})');
		// trace(haxe.Json.stringify(data, null, '\t'));
		if (this.humanReadable) {
			data = haxe.Json.stringify(data, null, '\t');
		} else {
			data = haxe.Json.stringify(data);
		}
		Fs.writeFileSync(DB_FILE,data,'utf8');
	}


	// ____________________________________ server stuff ____________________________________


	public function startServer(?port:Int){

		if(port == null) port = PORT;

		var server = Http.createServer(function(req, res){

			//use querystring module on query strings and stores in 'query' object
			var parseUrl = Url.parse(req.url, true, true);
			var statusCode = 404;
			var content = "404 - Not Found";

			// req.setTimeout(3000);


			// GET /addresses/1
			// POST /addresses
			// PUT /addresses/1
			// PATCH /addresses/1
			// DELETE /addresses/1

			//simple routing
			if(parseUrl.pathname == "/set"){
				console.log("Inserting value into database:",parseUrl.query);
				statusCode = 200;

				//retrieve current state of file (async)
				// getData(function(err,dataString){

				// 	if(err != null)
				// 		throw err;


				// 	//parse json string
				// 	var data = haxe.Json.parse(dataString);



				// 	//assign new query object's contents. don't forget previous state of 'data'
				// 	untyped Object.assign(data,parseUrl.query,data);

				// 	//persist data in file (async)
				// 	setData(data, function(err){
				// 		if(err != null)
				// 			throw err;

				// 		content = "Data inserted";
				// 		res.writeHead(statusCode,{"Content-Type":"text/plain"});
				// 		res.end(content);
				// 	});

				// });

			} else if(parseUrl.pathname.indexOf("/get") != -1){
				var searchKey = untyped parseUrl.query.key;
				var getContent = {};
				console.log("parseUrl: ",parseUrl);
				console.log("parseUrl.query: ",parseUrl.query);
				console.log("searchKey: key="+searchKey);
				statusCode = 200;

				trace('has(searchKey) : ${has(searchKey)}');
				trace('get(searchKey) : ${get(searchKey)}');

				// trace(parseUrl.search == '');
				// trace(this.serverdata);
				// trace(haxe.Json.stringify(this.serverdata));

				if(parseUrl.search == ''){
					// content = haxe.Json.stringify('${this.serverdata}');
					getContent = this.serverdata;
				} else if(has(searchKey)){
					var obj = {};
					Reflect.setField(obj, searchKey, get(searchKey) );
					getContent = obj;
				} else {
					getContent = {error: true};
				}

				// res.writeHead(statusCode,{"Content-Type":"text/plain"});
				res.writeHead(statusCode,{"Content-Type":"application/json"});
				res.end(haxe.Json.stringify(getContent));

			}else{
				// res.writeHead(statusCode,{"Content-Type":"text/plain"});
				res.writeHead(statusCode,{"Content-Type":"application/json"});
				res.end(content);
			}

		});
		// }).listen(4000);




		trace('http://localhost:4000/get/name');
		trace('http://localhost:4000/get?name');
		trace('http://localhost:4000/get?key=name');


		server.setTimeout(3000, function (socket):Void{
		 	server.close();
  			console.log("Call close");
		});
		server.listen(4000);

	}

	function server(){
		// Http.createServer(function (req, res) {
	 //      res.writeHead(200, {'Content-Type': 'text/plain'});
	 //      res.end('Hello World\n');
  //       }).listen(1337, '127.0.0.1');
  //       console.log('Server running at http://127.0.0.1:1337/');
  //
  //       // Workers can share any TCP connection
			// In this case its a HTTP server
			Http.createServer(function(req, res) {
				res.writeHead(200);
				res.end("hello world\n");
			}).listen(4000);

	}

}