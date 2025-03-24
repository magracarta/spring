<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > MS관리 > MS리스트관리 > null > 엑셀업로드
-- 작성자 : 성현우
-- 최초 작성일 : 2020-08-03 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;

		var makerCdJson = JSON.parse('${codeMapJsonObj['MAKER']}'); // 메이커코드
		var msMachineTypeCdJson = JSON.parse('${codeMapJsonObj['MS_MACHINE_TYPE']}'); // 기종코드
		var msCodeMap = JSON.parse('${codeMapJsonObj['MS_MACHINE_SUB_TYPE']}'); // 규격코드

		var msMchSubJsonArr = ${msMchSubJsonArr};
		var areaJson = ${areaList};

		$(document).ready(function() {
			// AUIGrid 생성
			createInitGrid();
			fileUploadInit();
		});

		function fileUploadInit() {
			// IE10, 11은 readAsBinaryString 지원을 안함. 따라서 체크함.
			var rABS = typeof FileReader !== "undefined" && typeof FileReader.prototype !== "undefined" && typeof FileReader.prototype.readAsBinaryString !== "undefined";

			// HTML5 브라우저인지 체크 즉, FileReader 를 사용할 수 있는지 여부
			function checkHTML5Brower() {
				var isCompatible = false;
				if (window.File && window.FileReader && window.FileList && window.Blob) {
					isCompatible = true;
				}
				return isCompatible;
			}

			// 파일 선택하기
			$('#fileSelector').on('change', function(evt) {
				if (!checkHTML5Brower()) {
					alert("브라우저가 HTML5 를 지원하지 않습니다.\r\n서버로 업로드해서 해결하십시오.");
					return;
				} else {
					var data = null;
					var file = evt.target.files[0];
					if (typeof file == "undefined") {
						alert("파일 선택 시 오류 발생!!");
						return;
					}
					var reader = new FileReader();

					reader.onload = function(e) {
						var data = e.target.result;

						/* 엑셀 바이너리 읽기 */
						var workbook;

						if(rABS) { // 일반적인 바이너리 지원하는 경우
							workbook = XLSX.read(data, {type: 'binary'});
						} else { // IE 10, 11인 경우
							var arr = fixdata(data);
							workbook = XLSX.read(btoa(arr), {type: 'base64'});
						}

						var jsonObj = process_wb(workbook);
						createAUIGrid( jsonObj[Object.keys(jsonObj)[0]] );
					};

					if(rABS) reader.readAsBinaryString(file);
					else reader.readAsArrayBuffer(file);

				}
			});
		}

		// IE10, 11는 바이너리스트링 못읽기 때문에 ArrayBuffer 처리 하기 위함.
		function fixdata(data) {
			var o = "", l = 0, w = 10240;
			for(; l<data.byteLength/w; ++l) o+=String.fromCharCode.apply(null,new Uint8Array(data.slice(l*w,l*w+w)));
			o+=String.fromCharCode.apply(null, new Uint8Array(data.slice(l*w)));
			return o;
		};

		// 파싱된 시트의 CDATA 제거 후 반환.
		function process_wb(wb) {
			var output = "";
			output = JSON.stringify(to_json(wb));
			output = output.replace( /<!\[CDATA\[(.*?)\]\]>/g, '$1' );
			return JSON.parse(output);
		};

		// 엑셀 시트를 파싱하여 반환
		function to_json(workbook) {

			var result = {};
			workbook.SheetNames.forEach(function(sheetName) {
				// JSON 으로 파싱
				var roa = XLSX.utils.sheet_to_row_object_array(workbook.Sheets[sheetName]);

				// CSV 로 파싱
				// var roa = XLSX.utils.sheet_to_csv( workbook.Sheets[sheetName] );

				if(roa.length > 0){
					result[sheetName] = roa;
				}
			});
			return result;
		}

		function convertCase(element) {
			var str = JSON.stringify(element);
			str = str.replace(/\"건설기계구분\":/g, "\"ms_machine_type_name\":");
			str = str.replace(/\"제작사명\":/g, "\"ms_maker_name\":");
			str = str.replace(/\"형식명\":/g, "\"ms_machine_name\":");
			str = str.replace(/\"규격\":/g, "\"ms_std_name\":");
			str = str.replace(/\"소유자주소\":/g, "\"ms_addr\":");
			str = str.replace(/\"등록일자\":/g, "\"ms_reg_dt\":");
			str = str.replace(/\"제작국\":/g, "\"ms_nation\":");
			element = JSON.parse(str);

			return element;
		}

		// 선택한 로우 삭제
		function fnRemove() {
			// 상단 그리드의 체크된 행들 얻기
			var rows = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if(rows.length <= 0) {
				alert('삭제할 데이터가 없습니다.');
				return;
			};
			// 선택한 상단 그리드 행들 삭제
			// 삭제하면  "이동" 이고, 삭제하지 않으면 "복사" 를 구현할 수 있음.
			AUIGrid.removeCheckedRows(auiGrid);
			fnUpdateCnt();
		}

		function fnUpdateCnt() {
			var cnt = AUIGrid.getGridData(auiGrid).length;
			$("#total_cnt").html(cnt);
		}

		// 액셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "엑셀내용");
		}

		// 파일업로드
		function goSearchFile() {
			$("#fileSelector").click();
		}

		// 필수 값 확인
		function fnConfirm() {

			var gridData = AUIGrid.getGridData(auiGrid);
			if(gridData.length == 0) {
				alert("체크할 데이터가 없습니다.");
				return;
			}
			if(fnCheckGridConfirmEmpty() == false) {
				alert("필수 항목은 반드시 값을 입력해야합니다.");
				return false;
			}

			var frm = $M.toValueForm(document.main_form);
			var option = {
				isEmpty : true
			};

			var ms_machine_type_name = []; // 건설기계구분
			var ms_maker_name = []; // 제작사명
			var ms_maker_cd = []; // 제작사 코드
			var ms_mch_plant_seq = []; // MS장비번호
			var ms_machine_name = []; // 형식명
			var ms_std_name = []; // 규격
			var ms_addr = []; // 소유자주소
			var ms_reg_dt = []; // 등록일자
			var ms_nation = []; // 제작국
			var uid = [];

			//  추가된 행 아이템들
			gridData = AUIGrid.getGridData(auiGrid);
			for(var i in gridData) {
				ms_machine_type_name.push(gridData[i].ms_machine_type_name);
				ms_maker_name.push(gridData[i].ms_maker_name);
				ms_maker_cd.push(gridData[i].ms_maker_cd);
				ms_mch_plant_seq.push(gridData[i].ms_mch_plant_seq);
				ms_machine_name.push(gridData[i].ms_machine_name);
				ms_std_name.push(gridData[i].ms_std_name);
				ms_addr.push(gridData[i].ms_addr);
				ms_reg_dt.push(gridData[i].ms_reg_dt);
				ms_nation.push(gridData[i].ms_nation);
				uid.push(gridData[i]._$uid);
			}

			$M.setValue(frm, "ms_machine_type_name_str", $M.getArrStr(ms_machine_type_name, option));
			$M.setValue(frm, "ms_maker_name_str", $M.getArrStr(ms_maker_name, option));
			$M.setValue(frm, "ms_maker_cd_str", $M.getArrStr(ms_maker_cd, option));
			$M.setValue(frm, "ms_mch_plant_seq_str", $M.getArrStr(ms_mch_plant_seq, option));
			$M.setValue(frm, "ms_machine_name_str", $M.getArrStr(ms_machine_name, option));
			$M.setValue(frm, "ms_std_name_str", $M.getArrStr(ms_std_name, option));
			$M.setValue(frm, "ms_addr_str", $M.getArrStr(ms_addr, option));
			$M.setValue(frm, "ms_reg_dt_str", $M.getArrStr(ms_reg_dt, option));
			$M.setValue(frm, "ms_nation_str", $M.getArrStr(ms_nation, option));
			$M.setValue(frm, "uid_str", $M.getArrStr(uid, option));

			$M.goNextPageAjax(this_page + "/setting", frm, {method: "POST"},
				function (result) {
					if (result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
						$M.setValue("confirm_yn", "Y");
					}
				}
			);
		}

		function goApply() {
			// 수정사항 체크
			var editedRowItems = AUIGrid.getEditedRowColumnItems(auiGrid);
			var columnArr = ["ms_machine_type_name", "ms_maker_name", "ms_machine_name", "ms_std_name", "ms_addr", "ms_reg_dt", "ms_nation"];
			var editCnt = 0;
			for(var i in editedRowItems) {
				for(var j=0; j<columnArr.length; j++) {
					if(AUIGrid.isEditedCell(auiGrid, editedRowItems[i]._$uid, columnArr[j])) {
						editCnt++;
					}
				}
			}

			if(editCnt > 0) {
				$M.setValue("confirm_yn", "N");
			}

			var gridData = AUIGrid.getGridData(auiGrid);
			if(gridData.length == 0) {
				alert("적용할 데이터가 없습니다.");
				return;
			}

			if($M.getValue("confirm_yn") == "N") {
				alert("필수 값 체크를 먼저 진행해주세요.");
				return;
			}

			if(fnCheckGridEmpty() == false) {
				alert("필수 항목은 반드시 값을 입력해야합니다.");
				return false;
			}

			var frm = $M.toValueForm(document.main_form);
			var option = {
				isEmpty : true
			};

			var ms_mon = []; // MS월
			var ms_machine_type_name = []; // 건설기계구분
			var ms_maker_name = []; // 제작사명
			var ms_maker_cd = []; // 제작사 코드
			var ms_mch_plant_seq = []; // MS장비번호
			var ms_machine_name = []; // 형식명
			var ms_std_name = []; // 규격
			var ms_addr = []; // 소유자주소
			var ms_reg_dt = []; // 등록일자
			var ms_nation = []; // 제작국
			var row_no = []; // 행번호

			var maker_cd = []; // 메이커코드
			var ms_machine_type_cd = []; // 기종코드
			var ms_machine_sub_type_cd = []; // 규격코드
			var sale_area_code = []; // 지역코드
			var remark = []; // 비고

			//  추가된 행 아이템들
			gridData = AUIGrid.getGridData(auiGrid);
			for(var i in gridData) {
				var msMon = gridData[i].ms_reg_dt.substr(0, 6);
				ms_mon.push(msMon);
				ms_machine_type_name.push(gridData[i].ms_machine_type_name);
				ms_maker_name.push(gridData[i].ms_maker_name);
				ms_maker_cd.push(gridData[i].ms_maker_cd);
				ms_mch_plant_seq.push(gridData[i].ms_mch_plant_seq);
				ms_machine_name.push(gridData[i].ms_machine_name);
				ms_std_name.push(gridData[i].ms_std_name);
				ms_addr.push(gridData[i].ms_addr);
				ms_reg_dt.push(gridData[i].ms_reg_dt);
				ms_nation.push(gridData[i].ms_nation);
				row_no.push(gridData[i].row_no);

				maker_cd.push(gridData[i].maker_cd);
				ms_machine_type_cd.push(gridData[i].ms_machine_type_cd);
				ms_machine_sub_type_cd.push(gridData[i].ms_machine_sub_type_cd);
				sale_area_code.push(gridData[i].sale_area_code);
				remark.push(gridData[i].remark);
			}

			$M.setValue(frm, "ms_mon_str", $M.getArrStr(ms_mon, option));
			$M.setValue(frm, "ms_machine_type_name_str", $M.getArrStr(ms_machine_type_name, option));
			$M.setValue(frm, "ms_maker_name_str", $M.getArrStr(ms_maker_name, option));
			$M.setValue(frm, "ms_maker_cd_str", $M.getArrStr(ms_maker_cd, option));
			$M.setValue(frm, "ms_machine_name_str", $M.getArrStr(ms_machine_name, option));
			$M.setValue(frm, "ms_std_name_str", $M.getArrStr(ms_std_name, option));
			$M.setValue(frm, "ms_addr_str", $M.getArrStr(ms_addr, option));
			$M.setValue(frm, "ms_reg_dt_str", $M.getArrStr(ms_reg_dt, option));
			$M.setValue(frm, "ms_nation_str", $M.getArrStr(ms_nation, option));
			$M.setValue(frm, "row_no_str", $M.getArrStr(row_no, option));

			$M.setValue(frm, "maker_cd_str", $M.getArrStr(maker_cd, option));
			$M.setValue(frm, "ms_machine_type_cd_str", $M.getArrStr(ms_machine_type_cd, option));
			$M.setValue(frm, "ms_machine_sub_type_cd_str", $M.getArrStr(ms_machine_sub_type_cd, option));
			$M.setValue(frm, "sale_area_code_str", $M.getArrStr(sale_area_code, option));
			$M.setValue(frm, "remark_str", $M.getArrStr(remark, option));
			$M.setValue(frm, "ms_mch_plant_seq_str", $M.getArrStr(ms_mch_plant_seq, option));

			if (!confirm("적용하시겠습니까?")) {
				return false;
			}

			$M.goNextPageAjax(this_page + "/save", frm, {method: "POST", timeout : 60 * 60 * 1000},
					function (result) {
						if (result.success) {
							alert("저장이 완료되었습니다.");
							fnClose();
							window.opener.goSearch();
						}
					}
			);
		}

		// 그리드 빈값 체크
		function fnCheckGridEmpty() {
			return AUIGrid.validateGridData(auiGrid, ["maker_cd", "ms_machine_type_cd", "ms_machine_sub_type_cd", "sale_area_code"], "필수 항목는 반드시 값을 입력해야 합니다.");
		}

		function fnCheckGridConfirmEmpty() {
			return AUIGrid.validateGridData(auiGrid, ["ms_machine_type_name", "ms_maker_name", "ms_machine_name", "ms_std_name", "ms_addr", "ms_reg_dt", "ms_nation"], "필수 항목는 반드시 값을 입력해야 합니다.");
		}

		// 닫기
		function fnClose() {
			window.close();
		}
		
		function setMsMachineSubType(data) {
			var list = [];
			var param = {
				"s_ms_machine_type_cd" : data
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), { method : 'GET'},
				function(result) {
					if(result.success) {
						list = result.list;
					}
				}
			);
		}

		// 엑셀 파일 시트에서 파싱한 JSON 데이터 기반으로 그리드 동적 생성
		function createAUIGrid(csvStr) {
			if(AUIGrid.isCreated(auiGrid)) {
				AUIGrid.destroy(auiGrid);
				auiGrid = null;
			}

			csvStr = convertCase(csvStr);
			var gridProps = {
				rowIdField : "_$uid",
				editable : true, // 수정 모드
				editableOnFixedCell : true,
				selectionMode : "multipleCells", // 다중셀 선택
				showStateColumn : true,
				//softRemoveRowMode 적용을 원래 데이터에만 적용 즉, 새 행인 경우 적용 안시킴
				softRemovePolicy :"exceptNew",
				wrapSelectionMove : true, // 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				enableFilter : true,
				softRemoveRowMode : false,
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				// fixedColumnCount : 7 // 고정칼럼 카운트 지정
			};

			var columnLayout = [
				{
					headerText : "건설기계구분",
					dataField : "ms_machine_type_name",
					style : "aui-center aui-editable",
					width : "7%",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "제작사명",
					dataField : "ms_maker_name",
					style : "aui-center aui-editable",
					width : "10%",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "형식명",
					dataField : "ms_machine_name",
					style : "aui-center aui-editable",
					width : "5%",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "규격",
					dataField : "ms_std_name",
					style : "aui-right aui-editable",
					width : "5%",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "소유자주소",
					dataField : "ms_addr",
					style : "aui-left aui-editable",
					width : "20%",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "등록일자",
					dataField : "ms_reg_dt",
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "8%",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "제작국",
					dataField : "ms_nation",
					style : "aui-center aui-editable",
					width : "5%",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "체크결과",
					dataField : "blank_check",
					style : "aui-center",
					width : "5%",
					editable : false,
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "메이커",
					dataField : "maker_name",
					style : "aui-center aui-popup",
					width : "10%",
					editable : false,
					filter : {
						showIcon : true
					},
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if(item.maker_cd == "") {
							return "메이커 선택";
						} else {
							return value;
						}

						return false;
					},
				},
				{
					headerText : "메이커코드",
					dataField : "maker_cd",
					visible : false
				},
				{
					headerText : "기종명",
					dataField : "ms_machine_type_cd",
					style : "aui-center aui-editable",
					width : "7%",
					showEditorBtn : false,
					showEditorBtnOver : false,
					editable : true,
					editRenderer : {
						type : "DropDownListRenderer",
						showEditorBtn : false,
						showEditorBtnOver : false,
						editable : true,
						list : msMachineTypeCdJson,
						keyField : "code_value",
						valueField  : "code_name",
						descendants : [ "ms_machine_sub_type_cd" ], // 자손 필드들
						descendantDefaultValues : [ "-" ], // 변경 시 자손들에게 기본값 지정
					},
					labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) {
						var retStr = value;
						for(var j = 0; j < msMachineTypeCdJson.length; j++) {
							if(msMachineTypeCdJson[j]["code_value"] == value) {
								retStr = msMachineTypeCdJson[j]["code_name"];
								break;
							}
						}
						return retStr;
					},
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "규격명",
					dataField : "ms_machine_sub_type_cd",
					style : "aui-right aui-editable",
					width : "7%",
					editable : true,
					showEditorBtn : false,
					showEditorBtnOver : false,
					editRenderer : {
						type : "DropDownListRenderer",
						showEditorBtn : false,
						showEditorBtnOver : false,
						editable : true,
						keyField : "code_value",
						valueField  : "code_name",
						listFunction : function(rowIndex, columnIndex, item, dataField) {
							return msMchSubJsonArr[item.ms_machine_type_cd];
						},
					},
					labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) {
						if (msMchSubJsonArr[item.ms_machine_type_cd]) {
							return msMchSubJsonArr[item.ms_machine_type_cd]
									.filter(obj => obj.code_value == value)
									.map(map => map.code_name)[0];
						}
						return value;
					},
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "지역",
					dataField : "sale_area_code",
					style : "aui-left aui-editable",
					width : "20%",
					showEditorBtn : false,
					showEditorBtnOver : false,
					editable : true,
					editRenderer : {
						type : "DropDownListRenderer",
						showEditorBtn : false,
						showEditorBtnOver : false,
						editable : true,
						list : areaJson,
						keyField : "sale_area_code",
						valueField  : "area_name"
					},
					labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) {
						var retStr = value;
						for(var j = 0; j < areaJson.length; j++) {
							if(areaJson[j]["sale_area_code"] == value) {
								retStr = areaJson[j]["area_name"];
								break;
							}
						}
						return retStr;
					},
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "비고",
					dataField : "remark",
					style : "aui-left aui-editable",
					width : "20%"
				},
				{
					headerText : "행번호",
					dataField : "row_no",
					visible : false
				},
				{
					headerText : "삭제",
					dataField : "removeBtn",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);
								AUIGrid.update(auiGrid);
							} else {
								AUIGrid.restoreSoftRows(auiGrid, "selectedIndex");
								AUIGrid.update(auiGrid);
							};

							$("#total_cnt").html(AUIGrid.getGridData(auiGrid).length);
						},
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : false,
				},
				{
					dataField : "ms_maker_cd",
					visible: false
				}
			];

			// 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridProps);

			// 그리드에 CSV 데이터 삽입
			// AUIGrid.setCsvGridData(auiGrid, csvStr, false);
			AUIGrid.setGridData(auiGrid, csvStr);
			$("#total_cnt").html(AUIGrid.getGridData(auiGrid).length);

			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == 'maker_name') {
					$M.setValue("maker_row_index", event.rowIndex);
					var params = {
						"parent_js_name" : "fnSetMaker",
					};
					var popupOption = "scrollbars=yes, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=400, left=0, top=0";
					$M.goNextPage('/sale/sale0504p02', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});
		};

		function fnSetMaker(data) {
			// alert(JSON.stringify(data));
			var rowIndex = $M.getValue("maker_row_index");
			var changeData = {
				"maker_cd" : data.maker_cd,
				"maker_name" : data.maker_name
			};

			AUIGrid.updateRow(auiGrid, changeData, rowIndex, false);
		}

		function parseCsv(value) {
			var rows = value.split("\n");
			var pData = [];
			for(var i=0, len=rows.length; i<len; i++) {
				pData[i] = rows[i].split(",");
			}
			return pData;
		}

		//그리드생성
		function createInitGrid() {
			var gridProps = {
				rowIdField : "_$uid",
				editable : true, // 수정 모드
				editableOnFixedCell : true,
				selectionMode : "multipleCells", // 다중셀 선택
				showStateColumn : true,
				//softRemoveRowMode 적용을 원래 데이터에만 적용 즉, 새 행인 경우 적용 안시킴
				softRemovePolicy :"exceptNew",
				wrapSelectionMove : true, // 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				enableFilter : true,
				softRemoveRowMode : false,
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				// fixedColumnCount : 7 // 고정칼럼 카운트 지정
			};

			var columnLayout = [
				{
					headerText : "건설기계구분",
					dataField : "ms_machine_type_name",
					style : "aui-center aui-editable",
					width : "7%",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "제작사명",
					dataField : "ms_maker_name",
					style : "aui-center aui-editable",
					width : "10%",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "형식명",
					dataField : "ms_machine_name",
					style : "aui-center aui-editable",
					width : "5%",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "규격",
					dataField : "ms_std_name",
					style : "aui-right aui-editable",
					width : "5%",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "소유자주소",
					dataField : "ms_addr",
					style : "aui-left aui-editable",
					width : "20%",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "등록일자",
					dataField : "ms_reg_dt",
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "8%",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "제작국",
					dataField : "ms_nation",
					style : "aui-center aui-editable",
					width : "5%",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "체크결과",
					dataField : "blank_check",
					style : "aui-center",
					width : "5%",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "메이커",
					dataField : "maker_cd",
					style : "aui-center aui-editable",
					width : "10%",
					showEditorBtn : false,
					showEditorBtnOver : false,
					editable : true,
					editRenderer : {
						type : "DropDownListRenderer",
						showEditorBtn : false,
						showEditorBtnOver : false,
						editable : true,
						list : makerCdJson,
						keyField : "code_value",
						valueField  : "code_name"
					},
					labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) {
						var retStr = value;
						for(var j = 0; j < makerCdJson.length; j++) {
							if(makerCdJson[j]["code_value"] == value) {
								retStr = makerCdJson[j]["code_name"];
								break;
							}
						}
						return retStr;
					},
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "기종명",
					dataField : "ms_machine_type_cd",
					style : "aui-center aui-editable",
					width : "7%",
					showEditorBtn : false,
					showEditorBtnOver : false,
					editable : true,
					editRenderer : {
						type : "DropDownListRenderer",
						showEditorBtn : false,
						showEditorBtnOver : false,
						editable : true,
						list : msMachineTypeCdJson,
						keyField : "code_value",
						valueField  : "code_name"
					},
					labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) {
						var retStr = value;
						for(var j = 0; j < msMachineTypeCdJson.length; j++) {
							if(msMachineTypeCdJson[j]["code_value"] == value) {
								retStr = msMachineTypeCdJson[j]["code_name"];
								break;
							}
						}
						return retStr;
					},
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "규격명",
					dataField : "ms_machine_sub_type_cd",
					style : "aui-right aui-editable",
					width : "7%",
					showEditorBtn : false,
					showEditorBtnOver : false,
					editable : true,
					editRenderer : {
						type : "DropDownListRenderer",
						showEditorBtn : false,
						showEditorBtnOver : false,
						editable : true,
						list : msCodeMap,
						keyField : "code_value",
						valueField  : "code_name"
					},
					labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) {
						var retStr = value;
						for(var j = 0; j < msCodeMap.length; j++) {
							if(msCodeMap[j]["code_value"] == value) {
								retStr = msCodeMap[j]["code_name"];
								break;
							}
						}
						return retStr;
					},
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "지역",
					dataField : "sale_area_code",
					style : "aui-left aui-editable",
					width : "20%",
					showEditorBtn : false,
					showEditorBtnOver : false,
					editable : true,
					editRenderer : {
						type : "DropDownListRenderer",
						showEditorBtn : false,
						showEditorBtnOver : false,
						editable : true,
						list : areaJson,
						keyField : "sale_area_code",
						valueField  : "area_name"
					},
					labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) {
						var retStr = value;
						for(var j = 0; j < areaJson.length; j++) {
							if(areaJson[j]["sale_area_code"] == value) {
								retStr = areaJson[j]["area_name"];
								break;
							}
						}
						return retStr;
					},
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "비고",
					dataField : "remark",
					style : "aui-left aui-editable",
					width : "20%"
				},
				{
					headerText : "행번호",
					dataField : "row_no",
					visible : false
				},
				{
					headerText : "삭제",
					dataField : "removeBtn",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);
								AUIGrid.update(auiGrid);
							} else {
								AUIGrid.restoreSoftRows(auiGrid, "selectedIndex");
								AUIGrid.update(auiGrid);
							};

							$("#total_cnt").html(AUIGrid.getGridData(auiGrid).length);
						},
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : false,
				},
				{
					dataField : "ms_maker_cd",
					visible: false
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridProps);
			AUIGrid.setGridData(auiGrid, []);

			// cellEditEndBefore 이벤트 바인딩
			AUIGrid.bind(auiGrid,  "cellEditEndBefore", function(event) {
				// 여기서 반환하는 값이 곧 적용 값입니다.
				// 개발자가 원하는 값으로 변경 가능합니다.
				if(event.isClipboard) {
					// return event.value + " [CP]"; // 원래값에 CP 붙이기
					return event.value;
				}
				return event.value; // 원래값
			});

			$("#auiGrid").resize();
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="confirm_yn" name="confirm_yn" value="N">
<input type="hidden" id="maker_row_index" name="maker_row_index">
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<div>
				<!-- 조회결과 -->
				<div class="title-wrap">
					<h4>Excel 내용</h4>
					<div class="right">
						<div class="form-check form-check-inline v-align-middle">
							<input type="checkbox" id="check_use_yn" name="check_use_yn" class="form-check-input" value="N">
							<label class="form-check-label" for="check_use_yn">기존데이터 삭제여부</label>
						</div>
						<input type="file" name="file_comp" id="fileSelector" style="display:none;width:5px;" accept=".xlsx" >
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 800px;"></div>
				<!-- /조회결과 -->
				<div class="btn-group mt5">
					<div class="left">
						총 <strong class="text-primary" id="total_cnt">0</strong>건
					</div>
				</div>
			</div>
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>