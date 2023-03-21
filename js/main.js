"use strict";

const clog = console.log;
const fileList = {};

let nesData, dbgData;
let nesDv;

$(function() {
	["smb1.asm"]
	.forEach(el => {
		$.ajax({
			type: "POST",
			url: `./asmFile/${el}`,
			data: "",
			dataType: "text"
		}).done(data => {
			fileList[el] = data;
		}).fail(data => {
			alert(data);
		});
	})

	$.ajax({
		type: "POST",
		url: "smb1.dbg",
		data: "",
		dataType: "text"
	}).done(data => {
		dbgData = data;
	}).fail(data => {
		alert(data);
	});

	$(document)
	.on('click', '#load_data', e => {
		let nesFiles = $('#nesfile')[0].files;
		let nesFile = nesFiles[0];
		if (!nesFiles.length || !nesFile) {
			alert('Please select both nes file.')
			return;
		}
		if (nesFile.size > 50 * 1024 * 1024) {  // 50 * 1000KB = 50MB
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
	})
	.on('click', '.get_variable_val', e => {
		let variableName = $(e.target).closest('div').find('.variable_name').val();
		let reg = new RegExp(variableName, "g");

		Object.keys(fileList).forEach(key => {
			let posArr = [];
			let reg2 = new RegExp(`id=(\\d+),name="${key}"`);
			let fileNum = dbgData.match(reg2)[0].replace(reg2, '$1');
			for(const el of fileList[key].matchAll(reg)) posArr.push(el.index);
			posArr.forEach(pos => {
				let tmp = fileList[key].slice(0, pos).match(/\r\n|\r|\n/g)
				let line = tmp ? tmp.length : 0;
				clog(`id=(\\d+),file=${fileNum},line=${line}`)
				let reg3 = new RegExp(`id=(\\d+),file=${fileNum},line=${line}`)
			});
		});
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
