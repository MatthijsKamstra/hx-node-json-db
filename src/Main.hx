package ;

import js.node.Http;
import js.Node.console;
import js.Node.*;

import js.node.Fs;
import js.node.Url;

import JsonDB;

/**
 * @author Matthijs Kamstra aka [mck]
 */
class Main{


	function new (){
		var db = new JsonDB();
		db.setData({
			'name' : "foo",
			'number' : 1,
			'float' : 1.1,
			string : "foo",
			array : [1,2,3],
			bool : true,
			obj : {one : 1,two : 2},
			date : Date.now()
		});
		trace(db.getData());

		db.set('test0', "one");
		db.set('test1', 2);
		db.set('test2', [1,2,3]);
		db.set('test3', true);
		db.set('test4', {foo:'ss'});
		trace(db.getData());
		trace(db.has('test0'));
		db.delete('test0');
		trace(db.has('test0'));

		db.push('arr0', {date: Date.now()});
		db.push('arr1' , [1,2,3,4]);
		db.push('arr2' , true);
		db.push('arr3' , 'foo');


		trace('------------------------');
		// [mck] next try
		// db.push('zep0' , {date: Date.now()});
		// db.push('step0/step1' , {date: Date.now()});
		// db.push('zero/one/two/three' , {date: Date.now()});

		// db.startServer();

		// var db2 = new JsonDB('database2', false);
		// db2.setData({test:'xxx', test2:4});
	}


	static public function main(){
		var main = new Main();
	}
}