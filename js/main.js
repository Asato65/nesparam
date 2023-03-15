"use strict";

const clog = console.log;

let nesData, dbgData;
let nesDv;

$(function() {
	$(document)
	.on('click', '#load_data', e => {
		let nesFiles = $('#nesfile')[0].files;
		let dbgFiles = $('#dbgfile')[0].files;
		let nesFile = nesFiles[0];
		let dbgFile = dbgFiles[0];
		/* develop
		if (!nesFiles.length || !dbgFiles.length || !nesFile || !dbgFile) {
			alert('Please select both nes and dbg file.')
			return;
		}*/
		if (nesFile.size + dbgFile.size > 50 * 1024 * 1024) {  // 50 * 1000KB = 50MB
			alert('File size over.');
			return true;
		}

		readBinary(nesFile)
		.then(data => {
			nesData = new Uint8Array(data);
			nesDv = new DataView(data);
		})
		.catch((err) => {
			alert(err);
		});

		readText(dbgFile)
		.then(data => {
			dbgData = data;
			// 値のセット方法： dbgDv.setUint8(1, 66);
		})
		.catch(err => {
			alert(err);
		});
	})
	.on('click', '.get_variable_val', e => {
		let variable_name = $(e.target).closest('div').find('.variable_name').val();
		let reg = new RegExp(`${variable_name} = .*$`);
		clog('reg: ', `name="${variable_name}"`)
		let res = dbgData.match(reg)//[0].slice(variable_name.length + 3);
		clog(res);
	})
});



function readBinary(file) {
	const reader = new FileReader();

	return new Promise((resolve, reject) => {
		reader.onerror = () => {
			reader.abort();
			reject('Binary load error.');
		}

		reader.onload = () => {
			clog('Load binary file.');
			resolve(reader.result);
		}

		reader.readAsArrayBuffer(file);
	});
}

function readText(file) {
	const reader = new FileReader();

	return new Promise((resolve, reject) => {
		reader.onerror = () => {
			reader.abort();
			reject('Text load error.');
		}

		reader.onload = () => {
			clog('Load text file.');
			resolve(reader.result);
		}

		reader.readAsText(file);
	});
}