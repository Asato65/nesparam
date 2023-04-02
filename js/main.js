"use strict";

// debug
const clog = console.log;

const fileList = {};
const fileNameArr = {};
const readFileList = [
	"./smb1.asm",
	"./sub.asm",
	"./inc/const_val.inc",
	"./inc/const_addr.inc",
	"./inc/map.inc",
	"./inc/plt_data.inc",
	"./inc/text_data.inc",
	"./inc/sound.inc",
	"./asm/macro.asm",
	"./asm/main.asm",
	"./asm/sub.asm",
	"./asm/move_chr.asm",
	"./asm/move_chr_x.asm",
	"./asm/move_chr_y.asm",
	"./asm/collision.asm",
	"./asm/anime.asm",
	"./asm/nmi.asm",
	"./asm/draw_map.asm",
	"./asm/status.asm",
	"./asm/sound.asm",
];

let nesData, dbgData;
let nesDv;

$(function() {
	readFileList.forEach(el => {
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
		url: "./asmFile/smb1.dbg",
		data: "",
		dataType: "text"
	}).done(data => {
		dbgData = data;
		let reg1 = new RegExp(`file\\tid=(\\d+),name="(.*?)"`, 'g');
		[...dbgData.matchAll(reg1)].forEach(el => {
			const id = el[0].replace(reg1, '$1');
			const name = el[0].replace(reg1, '$2');
			fileNameArr[id] = name;
		});
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
		let varName = $(e.target).siblings('.variable_name').val();
		let reg1 = new RegExp(`${varName} = (.*?)`);
		Object.keys(fileList).forEach(fileName => {
			let targetFile = fileList[fileName];
			let matchRes1 = targetFile.match(reg1);
			if (matchRes1) {
				let reg2 = new RegExp(`sym\\tid=\\d+,name="${varName}",addrsize=(.*?),scope=.*?,def=.*?,ref=.*?,val=0x(.*?),`);
				let matchRes2 = dbgData.match(reg2);
				if (matchRes2) {
					let addrSize = matchRes2[0].replace(reg2, '$1');
					let val = matchRes2[0].replace(reg2, '$2');
					val = (addrSize == 'absolute') ? val.padStart(4, '0') : val.padStart(2, '0');
					$(e.target).siblings('.variable_val').val(`$${val}`);
				}
			}
		});
	})
	.on('click', '.set_variable_val', e => {
		let varName = $(e.target).siblings('.variable_name').val();
		let varVal = $(e.target).siblings('.variable_val').val();
		let reg1 = new RegExp(`([$%]?)([0-9A-F]*)`);
		let matchRes1 = varVal.match(reg1);
		if (!matchRes1) { console.log("nomatch!!"); return false; }
		let sign = matchRes1[0].replace(reg1, '$1');
		let setVal = matchRes1[0].replace(reg1, '$2');
		if (sign == "%") {
			// TODO: 01以外の値が来たときの処理
			setVal = parseInt(setVal, 2).toString(16);
		} else if (sign == "") {
			setVal = parseInt(setVal, 10).toString(16);
		}

		let reg2 = new RegExp(`sym\\tid=\\d+,name="${varName}",addrsize=(.*?),scope=.*?,def=.*?,ref=(.*?),val=(.*?),`);
		let matchRes2 = dbgData.match(reg2);
		if (!matchRes2) { console.log('nomatch2'); return false; }
		let addrSize = matchRes2[0].replace(reg2, '$1');
		let ref = matchRes2[0].replace(reg2, '$2').split('+');
		let size = matchRes2[0].replace(reg2, '$3').length - 2 > 2 ? 2 : 1;
		if (setVal.length <= size * 2) setVal = setVal.padStart(size, '0');
		else { alert("値が大きすぎます。"); return false; }
		ref.forEach(id => {
			let reg3 = new RegExp(`line\\tid=${id},file=\\d+,line=\\d+,span=(\\d+)`);
			let matchRes3 = dbgData.match(reg3);
			if (!matchRes3) { console.log('nomatch'); return false; }
			let span = matchRes3[0].replace(reg3, '$1');
			let reg4 = new RegExp(`span\\tid=${span},seg=\\d+,start=(\\d+)`);
			let matchRes4 = dbgData.match(reg4);
			if (!matchRes4) { console.log('nomatch'); return false; }
			let startPos = +matchRes4[0].replace(reg4, '$1') + 1 + 16;
			if (size == 1) {
				let lowerVal = parseInt(setVal.slice(0, 2), 16);
				clog('startPos:', startPos)
				clog('lowerVal:', lowerVal)
				nesData[startPos] = lowerVal;
			} else {
				let upperVal = parseInt(setVal.slice(0, 2), 16);
				let lowerVal = parseInt(setVal.slice(2, 4), 16);
				nesData[startPos] = lowerVal;
				nesData[startPos+1] = upperVal;
			}

			let tmpTag = document.createElement("a");
			let blob = new Blob([nesData.buffer], {type: "application/octet-stream"});
			let url = window.URL.createObjectURL(blob);
			document.body.appendChild(tmpTag);
			tmpTag.style = "display: none";
			tmpTag.href = url;
			tmpTag.download = "smb1.nes";
			tmpTag.click();
			window.URL.revokeObjectURL(url);
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
