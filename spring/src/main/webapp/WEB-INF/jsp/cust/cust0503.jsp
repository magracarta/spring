<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객 App관리 > 장비컨텐츠관리 > null > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2023-07-10 13:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var codeMapCMchDataArray = JSON.parse('${codeMapJsonObj['C_MCH_DATA']}');

		var auiGrid;
		var auiGridData;
		var auiGridVideo;
		var auiGridCycle;

		var videoGridData;

		var cellRowIndex = 0;	// 버튼권한 설정 후 셀클릭 위치지정

		$(document).ready(function () {
			fnInit();
		});

		function fnInit() {
			createAUIGrid();
			createAUIGridData();
			createAUIGridVideo();
			createAUIGridCycle();

			goSearch();

			<c:forEach var="repFile" items="${detailInfo}">fnPrintFile('${detailInfo.rep_file_seq}', '${detailInfo.rep_file_name}', 'rep');</c:forEach>
<%--			<c:forEach var="dtlFile" items="${detailInfo}">fnPrintFile('${detailInfo.dtl_file_seq}', '${detailInfo.dtl_file_name}', 'dtl');</c:forEach>--%>
			<c:forEach var="partFile" items="${detailInfo}">fnPrintFile('${detailInfo.part_file_seq}', '${detailInfo.part_file_name}', 'part');</c:forEach>
		}

		// 대표이미지 파일첨부팝업
		function goRepFileUploadPopup() {
			var param = {
				upload_type : 'MACHINE',
				file_type : 'img',
				file_ext_type : '',
				max_width : 360,
				max_height : 400
			}
			openFileUploadPanel('fnSetFileRep', $M.toGetParam(param));
		}

		function fnSetFileRep(file) {
			fnPrintFileRep(file.file_seq, file.file_name);
		}

		// 대표이미지 파일세팅
		function fnPrintFileRep(fileSeq, fileName) {
			var str = '';
			str += '<div class="table-attfile-item submit_rep">';
			str += '<a href="javascript:fileDownload(' + fileSeq + ');">' + fileName + '</a>&nbsp;';
			str += '<input type="hidden" name="rep_file_seq" value="' + fileSeq + '"/>';
			str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveFileRep()"><i class="material-iconsclose font-18 text-default"></i></button>';
			str += '</div>';
			$('.submit_div_rep').append(str);
			$("#btn_submit_rep_file").remove();
		}

		// 대표이미지 첨부파일 삭제
		function fnRemoveFileRep() {
			var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
			if (result) {
				$(".submit_rep").remove();
				var str = '<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goRepFileUploadPopup()" id="btn_submit_rep_file">파일찾기</button>'
				$('.submit_div_rep').append(str);
				$M.setValue("rep_file_seq", "0");
			} else {
				return false;
			}
		}

		// 첨부파일 리셋
		function fnResetFile() {
			$(".submit_rep").remove();
			$("#btn_submit_rep_file").remove();
			var str = '<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goRepFileUploadPopup()" id="btn_submit_rep_file">파일찾기</button>'
			$('.submit_div_rep').append(str);

			// $(".submit_dtl").remove();
			// $("#btn_submit_dtl_file").remove();
			// var str = '<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goDtlFileUploadPopup()" id="btn_submit_dtl_file">파일찾기</button>'
			// $('.submit_div_dtl').append(str);
			// $('.dtl_file_div').append(str);

			$(".attDtlFileDiv").remove();
			$("#btn_submit_dtl_file").remove();
			var str = '<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goDtlFileUploadPopup()" id="btn_submit_dtl_file">파일찾기</button>'
			// $('.submit_div_dtl').append(str);
			$('.dtl_file_div').append(str);
			// $(".dtlAddFileDiv").remove();

			$(".submit_part").remove();
			$("#btn_submit_part_file").remove();
			var str = '<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goPartFileUploadPopup()" id="btn_submit_part_file">파일찾기</button>'
			$('.submit_div_part').append(str);

			$(".introFileDiv").remove();
			$("#btn_submit_intro_file").remove();
			var str = '<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goAddFileIntroPopup();" id="btn_submit_intro_file">파일찾기</button>'
			$('.intro_file_div').append(str);
		}

		// 상세이미지 첨부파일 index 변수
		var dtlFileIndex = 1;

		// 상세이미지 파일추가
		function goDtlFileUploadPopup() {
			var machinePlantSeq = $M.getValue("machine_plant_seq");
			if (machinePlantSeq == "") {
				alert("모델을 선택해주세요.");
				return;
			}
			// if($("input[name='dtl_file_seq']").size() >= addFileCount) {
			// 	alert("상세이미지 파일은 " + addFileCount + "개만 첨부하실 수 있습니다.");
			// 	return false;
			// }

			var dtlFileSeqArr = [];
			var dtlFileSeqStr = "";
			$("[name=dtl_file_seq]").each(function() {
				dtlFileSeqArr.push($(this).val());
			});

			dtlFileSeqStr = $M.getArrStr(dtlFileSeqArr);

			var dtlFileParam = "";
			if("" != dtlFileSeqStr) {
				dtlFileParam = '&file_seq_str='+dtlFileSeqStr;
			}

			openFileUploadMultiPanel('setDtlFileInfo', 'upload_type=MACHINE&file_type=img&total_max_count=0'+dtlFileParam);
		}

		// 상세이미지 파일세팅
		function setDtlFileInfo(result) {
			$(".attDtlFileDiv").remove(); // 파일영역 초기화
			dtlFileIndex = 1;
			var dtlFileList = result.fileList;  // 공통 파일업로드(다중) 에서 넘어온 file list
			for (var i = 0; i < dtlFileList.length; i++) {
				if(dtlFileList[i].file_seq != ""){
					fnPrintDtlFile(dtlFileList[i].file_seq, dtlFileList[i].file_name);
				}
			}
		}

		// 상세이미지 첨부파일 출력 (멀티)
		function fnPrintDtlFile(fileSeq, fileName) {
			var str = '';
			str += '<div class="table-attfile-item dtl_file_' + dtlFileIndex + ' attDtlFileDiv"style="float:left; display:block;">';
			str += '<a href="javascript:fileDownload(' + fileSeq + ');" style="color: blue; vertical-align: middle;">' + fileName + '</a>&nbsp;';
			str += '<input type="hidden" name="dtl_file_seq" value="' + fileSeq + '"/>';
			str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveDtlFile(' + dtlFileIndex + ', ' + fileSeq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
			str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
			str += '</div>';
			$('.dtl_file_div').append(str);
			dtlFileIndex++;
		}

		// 상세이미지 첨부파일 삭제
		function fnRemoveDtlFile(fileIndex, fileSeq) {
			var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
			if (result) {
				// fileChangeYn = 'Y';
				$(".dtl_file_" + fileIndex).remove();
				dtlFileIndex--;
			} else {
				return false;
			}
		}

		// 상세이미지 파일세팅
		function setDtlImgFileInfo(result) {
			$(".attDtlFileDiv").remove(); // 파일영역 초기화

			var dtlFileList = result.dtlImgList;  // 공통 파일업로드(다중) 에서 넘어온 file list
			for (var i = 0; i < dtlFileList.length; i++) {
				if(dtlFileList[i].file_seq != ""){
					fnPrintDtlFile(dtlFileList[i].dtl_img_file_seq, dtlFileList[i].dtl_img_file_name);
				}
			}
		}

		// // 상세이미지 파일첨부팝업
		// function goDtlFileUploadPopup() {
		// 	var param = {
		// 		upload_type : 'MACHINE',
		// 		file_type : 'img',
		// 		file_ext_type : '',
		// 		max_width : 600,
		// 		max_height : 0
		// 	}
		// 	openFileUploadPanel('fnSetFileDtl', $M.toGetParam(param));
		// }
		//
		// function fnSetFileDtl(file) {
		// 	fnPrintFileDtl(file.file_seq, file.file_name);
		// }
		//
		// // 상세이미지 파일세팅
		// function fnPrintFileDtl(fileSeq, fileName) {
		// 	var str = '';
		// 	str += '<div class="table-attfile-item submit_dtl">';
		// 	str += '<a href="javascript:fileDownload(' + fileSeq + ');">' + fileName + '</a>&nbsp;';
		// 	str += '<input type="hidden" name="dtl_file_seq" value="' + fileSeq + '"/>';
		// 	str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveFileDtl()"><i class="material-iconsclose font-18 text-default"></i></button>';
		// 	str += '</div>';
		// 	$('.submit_div_dtl').append(str);
		// 	$("#btn_submit_dtl_file").remove();
		// }
		//
		// // 상세이미지 첨부파일 삭제
		// function fnRemoveFileDtl() {
		// 	var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
		// 	if (result) {
		// 		$(".submit_dtl").remove();
		// 		var str = '<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goDtlFileUploadPopup()" id="btn_submit_dtl_file">파일찾기</button>'
		// 		$('.submit_div_dtl').append(str);
		// 		$M.setValue("dtl_file_seq", "0");
		// 	} else {
		// 		return false;
		// 	}
		// }

		// 부품위치 이미지 파일첨부팝업
		function goPartFileUploadPopup() {
			var param = {
				upload_type : 'MACHINE',
				file_type : 'img',
				file_ext_type : '',
				max_width : 716,
				max_height : 476
			}
			openFileUploadPanel('fnSetFilePart', $M.toGetParam(param));
		}

		function fnSetFilePart(file) {
			fnPrintFilePart(file.file_seq, file.file_name);
		}

		// 부품위치 이미지 파일세팅
		function fnPrintFilePart(fileSeq, fileName) {
			var str = '';
			str += '<div class="table-attfile-item submit_part">';
			str += '<a href="javascript:fileDownload(' + fileSeq + ');">' + fileName + '</a>&nbsp;';
			str += '<input type="hidden" name="part_file_seq" value="' + fileSeq + '"/>';
			str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveFilePart()"><i class="material-iconsclose font-18 text-default"></i></button>';
			str += '</div>';
			$('.submit_div_part').append(str);
			$("#btn_submit_part_file").remove();
		}

		// 부품위치 이미지 첨부파일 삭제
		function fnRemoveFilePart() {
			var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
			if (result) {
				$(".submit_part").remove();
				var str = '<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goPartFileUploadPopup()" id="btn_submit_part_file">파일찾기</button>'
				$('.submit_div_part').append(str);
				$M.setValue("part_file_seq", "0");
			} else {
				return false;
			}
		}

		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_machine_name"];
			$.each(field, function () {
				if (fieldObj.name == this) {
					goSearch();
				}
			});
		}

		function goSearch(callBackFnc) {
			var frm = document.main_form;

			var param = {
				"s_machine_name": $M.getValue("s_machine_name"),
				"s_maker_cd": $M.getValue("s_maker_cd"),
				"s_rfq_show_yn": $M.getValue("s_rfq_show_yn"),
				"s_use_yn": $M.getValue("s_use_yn"),
				"s_sale_yn" : $M.getValue("s_sale_yn"),
				"s_machine_type_cd" : $M.getValue("s_machine_type_cd")
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'GET'},
				function (result) {
					if (result.success) {
						fnClear();
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
						if (callBackFnc && typeof callBackFnc == "function") {
							callBackFnc();
						}
					}
				}
			);
		}

		// 입력내용 초기화
		function fnClear() {
			AUIGrid.setGridData(auiGridData, []);
			AUIGrid.setGridData(auiGridVideo, []);
			AUIGrid.setGridData(auiGridCycle, []);
			var param = {
				dtl_file_name : "",
				// dtl_file_seq : "0",
				dtl_text : "",
				intro_file_seq_1 : "0",
				intro_file_seq_2 : "0",
				intro_file_seq_3 : "0",
				intro_file_seq_4 : "0",
				intro_file_seq_5 : "0",
				machine_name : "",
				machine_plant_seq : "",
				part_file_name : "",
				part_file_seq : "0",
				rep_file_name : "",
				rep_file_seq : "0",
				rfq_show_yn : "N",
				search_text : "",
				use_yn : "Y",
				// sale_yn : "N",
			}
			$M.setValue(param);
			fnResetFile();
		}

		function createAUIGrid() {
			var gridPros = {
				editable: false,
				showRowCheckColumn: false,
				showRowNumColumn: true,
			};

			var columnLayout = [
				{
					headerText: "메이커",
					dataField: "maker_name",
					width : "100",
					minWidth : "60"
				},
				{
					headerText: "모델명",
					dataField: "machine_name",
					width : "150",
					minWidth : "60",
					style : "aui-left aui-link"
				},
				{
					headerText: "견적공개여부",
					dataField: "rfq_show_yn",
					width : "100",
					minWidth : "70"
				},
				{
					headerText: "판매여부",
					dataField: "sale_yn",
					width : "70",
					minWidth : "70"
				},
				{
					headerText: "사용여부",
					dataField: "use_yn",
					width : "70",
					minWidth : "70"
				},
				{
					dataField: "machine_plant_seq",
					visible: false
				},
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function (event) {
				cellRowIndex = event.rowIndex;
				$M.setValue("machine_plant_seq", event.item.machine_plant_seq);
				goSearchDetail($M.getValue("machine_plant_seq"));
			});
		}

		function createAUIGridData() {
			var gridPros = {
				editable: true,
				showRowCheckColumn: false,
				showRowNumColumn: true,
				rowIdField : "_$uid",
			};

			var columnLayout = [
				{
					dataField : "seq_no",
					visible : false
				},
				{
					dataField : "c_mch_data_name",
					visible : false
				},
				{
					headerText : "제원",
					dataField : "c_mch_data_cd",
					width : "20%",
					style : "aui-center",
					editable : true,
					editRenderer : {
						type : "ConditionRenderer",
						conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
							return myDropEditRenderer;
						},
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item ) {
						var retStr = value;
						for(var i = 0, len = codeMapCMchDataArray.length; i < len; i++) {
							if(codeMapCMchDataArray[i]["code_value"] == value) {
								retStr = codeMapCMchDataArray[i]["code_name"];
								AUIGrid.updateRow(auiGridData, {"c_mch_data_name" : value}, rowIndex);
								break;
							}
						}
						return retStr;
					},
				},
				{
					headerText: "제원정보",
					dataField: "data_value",
					editable : true,
					style : "aui-left aui-editable",
				},
				{
					headerText : "삭제",
					dataField : "removeBtn",
					width : "80",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGridData, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);
							} else {
								AUIGrid.restoreSoftRows(auiGridData, "selectedIndex");
							}
						}
					},
					labelFunction : function(rowIndex, columnIndex, value,
											 headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : true
				},
			];

			auiGridData = AUIGrid.create("#auiGridData", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridData, []);
		}

		// 조건부 에디트렌더러 출력(드랍다운리스트)
		var myDropEditRenderer = {
			showEditorBtnOver : true, // 마우스 오버 시 에디터버턴 보이기
			type : "DropDownListRenderer",
			keyField : 'code_value',
			valueField : 'code_name',
			list : codeMapCMchDataArray,
			editable : false,
			required : true,
			multipleMode : false
		};

		function createAUIGridVideo() {
			var gridPros = {
				editable: true,
				showRowCheckColumn: false,
				showRowNumColumn: true,
				rowIdField : "_$uid",
			};

			var columnLayout = [
				{
					headerText: "유튜브 URL",
					dataField: "video_url",
					style : "aui-left aui-editable",
				},
				{
					headerText : "삭제",
					dataField : "removeBtn",
					width : "80",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGridVideo, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.updateRow(auiGridVideo, {cmd : "D"}, event.rowIndex);
								AUIGrid.removeRow(event.pid, event.rowIndex);
							} else {
								AUIGrid.restoreSoftRows(auiGridVideo, "selectedIndex");
								AUIGrid.updateRow(auiGridVideo, {cmd : ""}, event.rowIndex);
							}
						}
					},
					labelFunction : function(rowIndex, columnIndex, value,
											 headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : true
				},
				{
					dataField : "cmd",
					visible : false
				},
			];

			auiGridVideo = AUIGrid.create("#auiGridVideo", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridVideo, []);

			AUIGrid.bind(auiGridVideo, "cellEditBegin", function (event) {
				videoGridData = AUIGrid.getGridData(auiGridVideo);
			});

			AUIGrid.bind(auiGridVideo, "cellEditEnd", function (event) {
				// 유튜브 URL 중복체크
				if (event.dataField == "video_url") {
					if (event.item.video_url != "") {
						fnVideoUrlCheck(event.item.video_url, event.rowIndex);
					}
				}
			});
		}

		// 저장
		function goSave() {
			var machinePlantSeq = $M.getValue("machine_plant_seq");
			if (machinePlantSeq == "") {
				alert("저장할 대상이 없습니다.");
				return;
			}

			if (fnCheckGridEmpty(auiGridData) === false){
				alert("필수 항목은 반드시 값을 입력해야합니다.");
				return false;
			}

			if (fnCheckGridEmpty1(auiGridVideo) === false){
				alert("필수 항목은 반드시 값을 입력해야합니다.");
				return false;
			}

			if (fnCheckGridEmpty2(auiGridCycle) === false){
				return false;
			}

			if (confirm("저장하시겠습니까 ?") == false) {
				return false;
			}

			var frm = $M.toValueForm(document.main_form);

			var introIdx = 1;
			$("input[name='intro_file_seq']").each(function() {
				if ($(this).attr("id") == undefined || $(this).attr("id") == '') {
					$M.setValue('intro_file_seq_' + introIdx, $(this).val());
				}
				introIdx++;
			});
			for(; introIdx <= introFileCount; introIdx++) {
				$M.setValue('intro_file_seq_' + introIdx, 0);
			}

			var fileArr = [];
			var fileSortNoArr = [];

			var dtlIdx = 1;
			$("input[name='dtl_file_seq']").each(function() {
				if ($(this).attr("id") == undefined || $(this).attr("id") == '') {
					// $M.setValue('dtl_file_seq_' + dtlIdx, $(this).val());
					fileArr.push($(this).val());
					fileSortNoArr.push(dtlIdx);
				}
				dtlIdx++;
			});
			// for(; dtlIdx <= dtlFileCount; dtlIdx++) {
			// 	$M.setValue('dtl_file_seq_' + dtlIdx, 0);
			// }

			// fileArr.forEach(item => {
			// 	var check = false;
			// 	// originFileList.forEach(oriFile => {
			// 	// 	if(oriFile.file_seq == item) {
			// 	// 		check = true;
			// 	// 	}
			// 	// });
			// 	if(!check) {
			// 		fileSeqArr.push(item);
			// 	}
			// });
			$M.setValue(frm, "dtl_img_file_seq_str", $M.getArrStr(fileArr));
			$M.setValue(frm, "dtl_img_file_sort_no_str", $M.getArrStr(fileSortNoArr));

			var seq_no = [];
			var c_mch_data_cd = [];
			var data_value = [];
			var data_cmd = [];

			var dataAddRows = AUIGrid.getAddedRowItems(auiGridData);
			var dataEditRows = AUIGrid.getEditedRowItems(auiGridData);
			var dataRemoveRows = AUIGrid.getRemovedItems(auiGridData);

			for (var i = 0; i < dataAddRows.length; i++) {
				seq_no.push(dataAddRows[i].seq_no);
				c_mch_data_cd.push(dataAddRows[i].c_mch_data_cd);
				data_value.push(dataAddRows[i].data_value);
				data_cmd.push("C");
			}

			for (var i = 0; i < dataEditRows.length; i++) {
				seq_no.push(dataEditRows[i].seq_no);
				c_mch_data_cd.push(dataEditRows[i].c_mch_data_cd);
				data_value.push(dataEditRows[i].data_value);
				data_cmd.push("U");
			}

			for (var i = 0; i < dataRemoveRows.length; i++) {
				seq_no.push(dataRemoveRows[i].seq_no);
				c_mch_data_cd.push(dataRemoveRows[i].c_mch_data_cd);
				data_value.push(dataRemoveRows[i].data_value);
				data_cmd.push("D");
			}

			var option = {
				isEmpty : true
			};

			$M.setValue(frm, "seq_no_str", $M.getArrStr(seq_no, option));
			$M.setValue(frm, "c_mch_data_cd_str", $M.getArrStr(c_mch_data_cd, option));
			$M.setValue(frm, "data_value_str", $M.getArrStr(data_value, option));
			$M.setValue(frm, "data_cmd_str", $M.getArrStr(data_cmd, option));

			var chg_seq_no = [];
			var chg_name = [];
			var chg_hour = [];
			var chg_cmd = [];
			var chg_use_yn = [];

			var dataAddRows2 = AUIGrid.getAddedRowItems(auiGridCycle);
			var dataEditRows2 = AUIGrid.getEditedRowItems(auiGridCycle);
			var dataRemoveRows2 = AUIGrid.getRemovedItems(auiGridCycle);

			for (var i = 0; i < dataAddRows2.length; i++) {
				chg_seq_no.push(dataAddRows2[i].seq_no);
				chg_name.push(dataAddRows2[i].chg_name);
				chg_hour.push(dataAddRows2[i].chg_hour);
				chg_cmd.push("C");
				chg_use_yn.push(dataAddRows2[i].use_yn);
			}

			for (var i = 0; i < dataEditRows2.length; i++) {
				chg_seq_no.push(dataEditRows2[i].seq_no);
				chg_name.push(dataEditRows2[i].chg_name);
				chg_hour.push(dataEditRows2[i].chg_hour);
				chg_cmd.push("U");
				chg_use_yn.push(dataEditRows2[i].use_yn);
			}

			for (var i = 0; i < dataRemoveRows2.length; i++) {
				chg_seq_no.push(dataRemoveRows2[i].seq_no);
				chg_name.push(dataRemoveRows2[i].chg_name);
				chg_hour.push(dataRemoveRows2[i].chg_hour);
				chg_cmd.push("U");
				chg_use_yn.push(dataRemoveRows2[i].use_yn);
			}

			$M.setValue(frm, "chg_seq_no_str", $M.getArrStr(chg_seq_no, option));
			$M.setValue(frm, "chg_name_str", $M.getArrStr(chg_name, option));
			$M.setValue(frm, "chg_hour_str", $M.getArrStr(chg_hour, option));
			$M.setValue(frm, "chg_cmd_str", $M.getArrStr(chg_cmd, option));
			$M.setValue(frm, "chg_use_yn_str", $M.getArrStr(chg_use_yn, option));

			if ($M.getValue("rfq_yn") == "") {
				$M.setValue("rfq_yn", "N");
			}

			if ($M.getValue("rental_yn") == "") {
				$M.setValue("rental_yn", "N");
			}

			var concatCols = [];
			var concatList = [];
			var gridIds = [auiGridVideo];
			for (var i = 0; i < gridIds.length; ++i) {
				concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
				concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
			}
			var gridFrm = fnGridDataToForm(concatCols, concatList);
			$M.copyForm(gridFrm, frm);

			$M.goNextPageAjax(this_page + "/save", gridFrm, {method : 'POST'},
				function(result) {
					if(result.success) {
						goSearch(function() {
							var colIndex = AUIGrid.getColumnIndexByDataField(auiGrid, "machine_name");
							AUIGrid.setSelectionByIndex("#auiGrid", cellRowIndex, colIndex);

							var machinePlantSeq = AUIGrid.getCellValue(auiGrid, cellRowIndex, "machine_plant_seq");
							goSearchDetail(machinePlantSeq);
						});
					}
				}
			);
		}

		// 모델 클릭시
		function goSearchDetail(machinePlantSeq) {
			var param = {
				"machine_plant_seq" : machinePlantSeq,
			};
			$M.goNextPageAjax(this_page + "/detail", $M.toGetParam(param),{ method : 'get'},
					function(result) {
						if(result.success){
							var detailInfo = result.detailInfo;
							$M.setValue(detailInfo);
							$M.setValue("dtl_file_seq", "");
							$('#sale_yn_text').html(detailInfo.sale_yn == 'Y' ? '판매' : '미판매');
							AUIGrid.setGridData(auiGridData, result.dataList);
							AUIGrid.setGridData(auiGridVideo, result.videoList);
							AUIGrid.setGridData(auiGridCycle, result.chgCycleList);
							fnResetFile();
							if (detailInfo.rep_file_seq != 0) {
								detailInfo.file_seq = detailInfo.rep_file_seq;
								detailInfo.file_name = detailInfo.rep_file_name;
								fnSetFileRep(detailInfo);
							}
							// if (detailInfo.dtl_file_seq != 0) {
							// 	detailInfo.file_seq = detailInfo.dtl_file_seq;
							// 	detailInfo.file_name = detailInfo.dtl_file_name;
							// 	// fnSetFileDtl(detailInfo);
							// }
							if (detailInfo.part_file_seq != 0) {
								detailInfo.file_seq = detailInfo.part_file_seq;
								detailInfo.file_name = detailInfo.part_file_name;
								fnSetFilePart(detailInfo);
							}

							setDtlImgFileInfo(result);
							setIntroFileInfo(result);
						}
					}
			);
		}

		//갱신
		function fnNew(machinePlantSeq) {
			var param = {
				machine_plant_seq : machinePlantSeq,
				use_yn : "Y",
				rfq_show_yn : "N",
			};

			$M.setValue(param);
		}

		// 항목코드관리 팝업 호출
		function goDataPopup() {
			var param = {};
			var popupOption = "";
			$M.goNextPage('/cust/cust0503p02', $M.toGetParam(param), {popupStatus : popupOption});
		}

		// 제원 행추가
		function fnAdd() {
			var machinePlantSeq = $M.getValue("machine_plant_seq");
			if (machinePlantSeq == "") {
				alert("모델을 먼저 선택해 주세요.");
				return false;
			}

			var colIndex = AUIGrid.getColumnIndexByDataField(auiGridData, "c_mch_data_cd");
			fnSetCellFocus(auiGridData, colIndex, "c_mch_data_cd");
			var item = new Object();
			if(fnCheckGridEmpty(auiGridData)) {
				item.seq_no = -1;
				item.c_mch_data_name = "";
				item.data_value = "";
				AUIGrid.addRow(auiGridData, item, 'last');
			}
		}

		// 그리드 빈값 체크 - 제원
		function fnCheckGridEmpty() {
			return AUIGrid.validateGridData(auiGridData, ["c_mch_data_cd", "data_value"], "필수 항목은 반드시 값을 입력해야합니다.");
		}

		// 유튜브 행추가
		function fnAddSec() {
			var machinePlantSeq = $M.getValue("machine_plant_seq");
			if (machinePlantSeq == "") {
				alert("모델을 먼저 선택해 주세요.");
				return false;
			}

			var colIndex = AUIGrid.getColumnIndexByDataField(auiGridVideo, "video_url");
			fnSetCellFocus(auiGridVideo, colIndex, "video_url");
			var item = new Object();
			if(fnCheckGridEmpty1(auiGridVideo)) {
				item.video_url = "";
				AUIGrid.addRow(auiGridVideo, item, 'last');
			}
		}

		// 그리드 빈값 체크 - 유튜브
		function fnCheckGridEmpty1() {
			return AUIGrid.validateGridData(auiGridVideo, ["video_url"], "필수 항목은 반드시 값을 입력해야합니다.");
		}

		// 미리보기 팝업 호출
		function goPreView() {
			var machinePlantSeq = $M.getValue("machine_plant_seq");
			if (machinePlantSeq == "") {
				alert("모델을 먼저 선택해 주세요.");
				return false;
			}

			var param = {
				"machine_plant_seq" : machinePlantSeq
			};
			var popupOption = "";
			$M.goNextPage('/cust/cust0503p01', $M.toGetParam(param), {popupStatus : popupOption});
		}

		// 유튜브 URL 중복체크
		function fnVideoUrlCheck(videoUrl, rowIndex) {
			var flag = "Y"; // 유튜브 URL 중복체크 변수

			for (var i = 0; i < videoGridData.length; i++) {
				if ($.trim(videoGridData[i].video_url) == $.trim(videoUrl)) {
					flag = "N";
				}
			}

			if (flag == "Y") {
				var param = {
					"video_url" : videoUrl,
					"machine_plant_seq" : $M.getValue("machine_plant_seq")
				}
				$M.goNextPageAjax("/cust/cust0503/duplicate/check", $M.toGetParam(param), {method : 'GET'},
						function(result) {
							if(result.success) {

							} else {
								AUIGrid.updateRow(auiGridVideo, { "video_url" : ""}, rowIndex);
								return;
							}
						}
				);
			} else {
				alert("유튜브 URL이 중복됩니다.");
				AUIGrid.updateRow(auiGridVideo, { "video_url" : ""}, rowIndex);
				return;
			}
		}

		// 카다로그 첨부파일 index 변수
		var introFileIndex = 1;
		// 카다로그 첨수할 수 있는 파일의 개수
		var introFileCount = 5;

		// 카다로그 파일추가
		function goAddFileIntroPopup() {
			if($("input[name='intro_file_seq']").size() >= introFileCount) {
				alert("파일은 " + introFileCount + "개만 첨부하실 수 있습니다.");
				return false;
			}

			var introFileSeqArr = [];
			var introFileSeqStr = "";
			$("[name=intro_file_seq]").each(function() {
				introFileSeqArr.push($(this).val());
			});

			introFileSeqStr = $M.getArrStr(introFileSeqArr);

			var introFileParam = "";
			if("" != introFileSeqStr) {
				introFileParam = '&file_seq_str='+introFileSeqStr;
			}

			openFileUploadMultiPanel('setIntroFileInfo', 'upload_type=MACHINE&file_type=both&total_max_count=5'+introFileParam);
		}

		// 카다로그 파일세팅
		function setIntroFileInfo(result) {
			$(".introFileDiv").remove(); // 파일영역 초기화
      $("#intro_file_seq").remove(); // q&a - 23367 저장 처리 시 input 이 남아있어 이전 값 물고가던 현상 제거
			for (var i = 1; i < 5; i++) {
				$M.setValue("intro_file_seq_"+i, "0");
			}

			var introFileList = result.fileList;  // 공통 파일업로드(다중) 에서 넘어온 file list
			console.log("introFileList : ", introFileList);
			for (var i = 0; i < introFileList.length; i++) {
				fnPrintIntroFile(introFileList[i].file_seq, introFileList[i].file_name);
			}
		}

		// 카다로그 첨부파일 출력 (멀티)
		function fnPrintIntroFile(fileSeq, fileName) {
			var str = '';
			str += '<div class="table-attfile-item intro_file_' + introFileIndex + ' introFileDiv"style="float:left; display:block;">';
			str += '<a href="javascript:fileDownload(' + fileSeq + ');" style="color: blue; vertical-align: middle;">' + fileName + '</a>&nbsp;';
			str += '<input type="hidden" name="intro_file_seq" value="' + fileSeq + '"/>';
			str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveIntroFile(' + introFileIndex + ', ' + fileSeq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
			str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
			str += '</div>';
			$('.intro_file_div').append(str);
			introFileIndex++;
		}

		// 카다로그 첨부파일 삭제
		function fnRemoveIntroFile(fileIndex, fileSeq) {
			var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
			if (result) {
				$(".intro_file_" + fileIndex).remove();
				$M.setValue("intro_file_seq_" + fileIndex, "0");
			} else {
				return false;
			}
		}

		// 교체주기 그리드
		function createAUIGridCycle() {
			var gridPros = {
				editable: false,
				showStateColumn : true,
				showRowNumColumn: true,
				fillColumnSizeMode : true,
				rowIdField : "_$uid",
				editable : true,
			};

			var columnLayout = [
				{
					dataField : "seq_no",
					visible : false
				},
				{
					headerText: "교체주기명",
					dataField: "chg_name",
					width : "100",
					minWidth : "60",
					style : "aui-left aui-editable",
					editable : true,
					editRenderer : {
						type : "InputEditRenderer",
						maxlength : 50,
						// 에디팅 유효성 검사
						validator : AUIGrid.commonValidator
					}
				},
				{
					headerText: "시간(h)",
					dataField: "chg_hour",
					dataType : "numeric",
					formatString : "#,###",
					width : "150",
					minWidth : "60",
					style : "aui-center aui-editable",
					editable : true,
					editRenderer : {
						type : "InputEditRenderer",
						onlyNumeric : true,
						autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
						allowPoint : false, // 소수점(.) 입력 가능 설정
						validator : AUIGrid.commonValidator
					},
				},
				{
					headerText : "삭제",
					dataField : "removeBtn",
					width : "60",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGridCycle, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.updateRow(auiGridCycle, { "use_yn" : "N", "cmd" : "U" }, event.rowIndex);
								AUIGrid.removeRow(event.pid, event.rowIndex);
							} else {
								AUIGrid.updateRow(auiGridCycle, { "use_yn" : "N", "cmd" : "D" }, event.rowIndex);
								AUIGrid.restoreSoftRows(auiGridCycle, "selectedIndex");
							}
						}
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : true
				},
				{
					dataField : "use_yn",
					visible : false
				},
				{
					dataField : "cmd",
					visible : false
				},
			];

			auiGridCycle = AUIGrid.create("#auiGridCycle", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridCycle, []);
		}

		// 교체주기 행추가
		function fnAddThird() {
			var machinePlantSeq = $M.getValue("machine_plant_seq");
			if (machinePlantSeq == "") {
				alert("모델을 먼저 선택해 주세요.");
				return false;
			}

			var colIndex = AUIGrid.getColumnIndexByDataField(auiGridCycle, "chg_name");
			fnSetCellFocus(auiGridCycle, colIndex, "chg_name");
			if(fnCheckGridEmpty2(auiGridCycle)) {
				var item = {
					"cmd": "C",
					"seq_no": 0,
					"chg_name": "",
					"chg_hour": "",
					"use_yn": "Y",
				}
				AUIGrid.addRow(auiGridCycle, item, 'last');
			}
		}
		// 그리드 빈값 체크 - 교체주기
		function fnCheckGridEmpty2() {
			if (AUIGrid.validateGridData(auiGridCycle, ["chg_name", "chg_hour"], "필수 항목은 반드시 값을 입력해야합니다.") == false) {
				return false;
			}
			var gridData = AUIGrid.getGridData(auiGridCycle);
			for(var i = 0; i < gridData.length; i++) {
				if(gridData[i].use_yn != "N" && gridData[i].chg_hour == 0) {
					alert("작성 시간은 0보다 커야합니다.");
					return false;
				}
			}

			return true;
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="machine_plant_seq" name="machine_plant_seq">
	<div class="layout-box">
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
				<!-- 메인 타이틀 -->
				<div class="main-title">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
				<!-- /메인 타이틀 -->
				<div class="contents">
					<!-- 기본 -->
					<div class="search-wrap">
						<table class="table">
							<colgroup>
								<col width="60px">
								<col width="120px">
								<col width="60px">
								<col width="150px">
								<col width="100px">
								<col width="120px">
								<col width="60px">
								<col width="120px">
								<col width="60px">
								<col width="120px">
								<col width="60px">
								<col width="120px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th>모델명</th>
								<td>
									<input type="text" class="form-control width120px" id="s_machine_name" name="s_machine_name">
								</td>
								<th>메이커</th>
								<td>
									<select class="form-control" id="s_maker_cd" name="s_maker_cd" onchange="javascript:goSearchMachineTypeByMaker(this.value);" >
										<option value="">- 전체 -</option>
										<c:forEach items="${codeMap['MAKER']}" var="item">
											<c:if test="${item.code_v1 eq 'Y' && item.code_v2 eq 'Y'}">
												<option value="${item.code_value}" ${item.code_value == inputParam.s_maker_cd ? 'selected="selected"' : ''}>${item.code_name}</option>
											</c:if>
										</c:forEach>
									</select>
								</td>
								<th>견적공개여부</th>
								<td>
									<select class="form-control" id="s_rfq_show_yn" name="s_rfq_show_yn">
										<option value="">전체</option>
										<option value="Y">공개</option>
										<option value="N">비공개</option>
									</select>
								</td>
								<th>사용여부</th>
								<td>
									<select class="form-control" id="s_use_yn" name="s_use_yn">
										<option value="">전체</option>
										<option value="Y">사용</option>
										<option value="N">미사용</option>
									</select>
								</td>
								<th>판매여부</th>
								<td>
									<select id="s_sale_yn" name="s_sale_yn" class="form-control">
										<option value="">- 전체 -</option>
										<option value="Y">판매</option>
										<option value="N">미판매</option>
									</select>
								</td>
								<th>기종</th>
								<td>
									<select class="form-control" id="s_machine_type_cd" name="s_machine_type_cd">
										<option value="">- 전체 -</option>
										<c:forEach items="${codeMap['MACHINE_TYPE']}" var="item">
											<c:if test="${item.code_v1 eq 'Y'}">
												<option value="${item.code_value}" ${item.code_value == inputParam.s_machine_type_cd ? 'selected="selected"' : ''}>${item.code_name}</option>
											</c:if>
										</c:forEach>
									</select>
								</td>
								<td class="">
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
							</tr>
							</tbody>
						</table>
					</div>

					<div class="row">
						<!-- 조회결과 -->
						<div class="col-4">
							<div class="title-wrap mt10">
								<h4>조회결과</h4>
							</div>
							<div id="auiGrid" style="margin-top: 5px;height: 635px;"></div>
						</div>
						<!-- /조회결과 -->
						<div class="col-8">
							<!-- 상세정보 -->
							<div class="row">
								<div class="col-12">
									<div class="title-wrap mt10">
										<h4>상세정보</h4>
									</div>
									<!-- 폼테이블 -->
									<div>
										<table class="table-border">
											<colgroup>
												<col width="85px"> <!-- 100에서 75로수정-->
												<col width="">
												<col width="85px">
												<col width="150px">
												<col width="75px"> <!-- 100에서 75로수정-->
												<col width="">
											</colgroup>
											<tbody>
											<tr>
												<th class="text-right">대표이미지</th>
												<td colspan="1">
													<div class="table-attfile submit_div_rep">
														<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goRepFileUploadPopup()" id="btn_submit_rep_file">파일찾기</button>
													</div>
												</td>
<%--												<th class="text-right">상세이미지</th>--%>
<%--												<td>--%>
<%--													<div class="table-attfile submit_div_dtl">--%>
<%--														<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goDtlFileUploadPopup()" id="btn_submit_dtl_file">파일찾기</button>--%>
<%--													</div>--%>
<%--												</td>--%>
												<th class="text-right">부품위치</br>이미지</th>
												<td colspan="3">
													<div class="table-attfile submit_div_part">
														<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goPartFileUploadPopup()" id="btn_submit_part_file">파일찾기</button>
													</div>
												</td>
											</tr>
											<tr>
												<th class="text-right">상세이미지</th>
												<td colspan="5">
													<div class="table-attfile dtl_file_div" style="width:100%;">
														<div class="table-attfile" style="float:left">
															<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goDtlFileUploadPopup();" id="btn_submit_dtl_file">파일찾기</button>
														</div>
													</div>
												</td>
											</tr>
											<tr>
												<th class="text-right">사용여부</th>
												<td>
													<div class="form-check form-check-inline">
														<input class="form-check-input" type="radio" name="use_yn" value="Y" id="use_yn_y">
														<label class="form-check-label" for="use_yn_y">사용</label>
													</div>
													<div class="form-check form-check-inline">
														<input class="form-check-input" type="radio" name="use_yn" value="N" id="use_yn_n">
														<label class="form-check-label" for="use_yn_n">미사용</label>
													</div>
												</td>
												<th class="text-right">견적공개여부</th>
												<td>
													<div class="form-check form-check-inline">
														<input class="form-check-input" type="radio" name="rfq_show_yn" value="Y" id="rfq_show_yn_y">
														<label class="form-check-label" for="rfq_show_yn_y">공개</label>
													</div>
													<div class="form-check form-check-inline">
														<input class="form-check-input" type="radio" name="rfq_show_yn" value="N" id="rfq_show_yn_n">
														<label class="form-check-label" for="rfq_show_yn_n">비공개</label>
													</div>
												</td>
												<th class="text-right">판매여부</th>
												<td>
													<span id="sale_yn_text"></span>
												</td>
											</tr>
											<tr>
												<th class="text-right">사용구분</th>
												<td colspan="1">
													<div class="form-check form-check-inline v-align-middle">
														<input type="checkbox" id="rfq_yn" name="rfq_yn" class="form-check-input" value="Y">
														<label class="form-check-label" for="rfq_yn">장비문의</label>
													</div>
													<div class="form-check form-check-inline v-align-middle">
														<input type="checkbox" id="rental_yn" name="rental_yn" class="form-check-input" value="Y">
														<label class="form-check-label" for="rental_yn">렌탈신청</label>
													</div>
												</td>
												<th class="text-right">검색키워드</th>
												<td colspan="3">
													<div class="form-row inline-pd">
														<div class="col-12">
															<input type="text" class="form-control" id="search_text" name="search_text" style="padding : 5px;" maxlength="100">
														</div>
													</div>
												</td>
											</tr>
											<tr>
												<th class="text-right">메뉴얼</th>
												<td colspan="5">
													<div class="table-attfile intro_file_div" style="width:100%;">
														<div class="table-attfile" style="float:left">
															<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goAddFileIntroPopup();" id="btn_submit_intro_file">파일찾기</button>
														</div>
													</div>
												</td>
											</tr>
											<tr>
												<th class="text-right">장비상세설명</th>
												<td colspan="5">
													<div class="form-row inline-pd">
														<div class="col-12">
															<textarea class="form-control" style="height: 150px;" id="dtl_text" name="dtl_text"></textarea>
														</div>
													</div>
												</td>
											</tr>
											</tbody>
										</table>
									</div>
									<!-- /폼테이블 -->
								</div>
							</div>
							<!-- /상세정보 -->
							<div class="row">
								<div class="col-6">
									<div class="title-wrap mt10">
										<h4>제원</h4>
										<div class="btn-group mt5 ml5">
											<div class="right">
												<button type="button" class="btn btn-default" style="width: 80px;" onclick="javascript:goDataPopup();">항목코드관리</button>
												<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_M"/></jsp:include>
											</div>
										</div>
									</div>
									<div id="auiGridData" style="margin-top: 5px; height: 300px;"></div>
								</div>
								<div class="col-6">
									<div class="title-wrap mt10">
										<h4>유튜브</h4>
										<div class="btn-group mt5 ml5">
											<div class="right">
												<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
											</div>
										</div>
									</div>
									<div id="auiGridVideo" style="margin-top: 5px; height: 128px;"></div>
									<div class="title-wrap mt10">
										<h4>교체주기표</h4>
										<div class="btn-group mt5 ml5">
											<div class="right">
												<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_M"/></jsp:include>
											</div>
										</div>
									</div>
									<div id="auiGridCycle" style="margin-top: 5px; height: 127px;"></div>
								</div>
							</div>
						</div>
						<div class="btn-group mt5 ml5">
							<div class="left">
								총 <strong class="text-primary" id="total_cnt">0</strong>건
							</div>
							<div class="right">
								<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goPreView();">미리보기</button>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
	<div>
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
	</div>
<input type="hidden" id="rep_file_seq" name="rep_file_seq" value="${detailInfo.rep_file_seq}" />
<%--<input type="hidden" id="dtl_file_seq" name="dtl_file_seq" value="${detailInfo.dtl_file_seq}" />--%>
<input type="hidden" id="part_file_seq" name="part_file_seq" value="${detailInfo.part_file_seq}" />
</form>
</body>
</html>