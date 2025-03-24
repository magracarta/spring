<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 인사코드관리 > null > null
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var makerHrSvcCdJson = JSON.parse('${codeMapJsonObj['MAKER_HR_SVC']}');			//자산물품구분
	
	var fileSeq;
	// 첨부파일의 index 변수
	var fileIndex = 1;
	// 첨부할 수 있는 파일의 개수
	var fileCount = 1;
	
	$(document).ready(function () {
		// 그리드 생성
		createAUIGrid();
		goSearch();
	});
	
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			rowIdTrustMode : true,
			showRowNumColumn: true,
			editable : true,
			enableFilter :true,
			showStateColumn : true,
			enableFocus : true
		};
		
		var columnLayout = [
			{
				headerText : "메이커",
				dataField : "maker_hr_svc_cd",
				width : "170",
				style : "aui-center",
				editable : false,
// 				editRenderer : {
// 					type : "DropDownListRenderer",
// 					showEditorBtn : false,
// 					showEditorBtnOver : false,
// 					list : makerHrSvcCdJson,
// 					keyField : "code_value", 
// 					valueField : "code_name" 				
// 				},
				labelFunction : function(rowIndex, columnIndex, value){
					for(var i=0; i<makerHrSvcCdJson.length; i++){
						if(value == makerHrSvcCdJson[i].code_value){
							return makerHrSvcCdJson[i].code_name;
						}
					}
					return value;
				},
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "단계",
				dataField : "",
				children : [
					{
						headerText : "A",
						dataField : "grade_a",
						width : "50",
						dataType : "numeric",
						style : "aui-center aui-editable",
						editable : true,
						editRenderer : {
						      type : "InputEditRenderer",
						      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
						},
					},
					{
						headerText : "B",
						dataField : "grade_b",
						width : "50",
						dataType : "numeric",
						style : "aui-center aui-editable",
						editable : true,
						editRenderer : {
						      type : "InputEditRenderer",
						      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
						},
					},
					{
						headerText : "C",
						dataField : "grade_c",
						width : "50",
						dataType : "numeric",
						style : "aui-center aui-editable",
						editable : true,
						editRenderer : {
						      type : "InputEditRenderer",
						      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
						},
					},
					{
						headerText : "D",
						dataField : "grade_d",
						width : "50",
						dataType : "numeric",
						style : "aui-center aui-editable",
						editable : true,
						editRenderer : {
						      type : "InputEditRenderer",
						      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
						},
					},
					{
						headerText : "E",
						dataField : "grade_e",
						width : "50",
						dataType : "numeric",
						style : "aui-center aui-editable",
						editable : true,
						editRenderer : {
						      type : "InputEditRenderer",
						      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
						},
					},
					{
						headerText : "F",
						dataField : "grade_f",
						width : "50",
						dataType : "numeric",
						style : "aui-center aui-editable",
						editable : true,
						editRenderer : {
						      type : "InputEditRenderer",
						      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
						},
					},
					{
						headerText : "G",
						dataField : "grade_g",
						width : "50",
						dataType : "numeric",
						style : "aui-center aui-editable",
						editable : true,
						editRenderer : {
						      type : "InputEditRenderer",
						      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
						},
					},
					{
						headerText : "H",
						dataField : "grade_h",
						width : "50",
						dataType : "numeric",
						style : "aui-center",
						editable : true,
						editRenderer : {
						      type : "InputEditRenderer",
						      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
						},
					},
				]
			},
			{
				headerText : "총 상승단계",
				dataField : "total_up_grade",
				width : "80",
				style : "aui-center aui-editable",
				dataType : "numeric",
				editRenderer : {
				      type : "InputEditRenderer",
				      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
				},
				editable : true,
				visible : false
			},
			{
				headerText : "총 상승연봉",
				dataField : "total_up_salary_amt",
				width : "120",
				style : "aui-right aui-editable",
				dataType : "numeric",
				editRenderer : {
				      type : "InputEditRenderer",
				      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
				},
				editable : true,
				visible : false
			},
			{
				headerText : "정렬순서",
				dataField : "sort_no",
				width : "65",
				style : "aui-center aui-editable",
				editable : true,
				visible : false
			},
			{
				headerText : "사용여부",
				dataField : "use_yn",
				width : "65",
				style : "aui-center",
				renderer : {
					type : "CheckBoxEditRenderer",
					editable : true,
					checkValue : "Y",
					unCheckValue : "N"
				},
				filter : {
					showIcon : true
				},
				visible : false
			},
		];
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros)
		AUIGrid.setGridData(auiGrid, []);
		
		AUIGrid.bind(auiGrid, "cellEditBegin", function (event) {
// 			if(event.dataField == "maker_hr_svc_cd") {
// 				// 추가된 행 아이템인지 조사하여 추가된 행인 경우만 에디팅 진입 허용
// 				if(AUIGrid.isAddedById(event.pid, event.item._$uid)) {
// 					return true;
// 				} else {
// 					setTimeout(function() {
// 						   AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "새로 추가된 행만 수정이 가능합니다.");
// 					}, 1);
// 					return false; // false 반환하면 기본 행위 안함(즉, cellEditBegin 의 기본행위는 에디팅 진입임)
// 				}
// 			}
		});
		
		AUIGrid.bind(auiGrid, "cellEditEndBefore", function (event) {
			if(event.dataField == "maker_hr_svc_cd") {
				var isUnique = AUIGrid.isUniqueValue(auiGrid, event.dataField, event.value);	
				if (isUnique == false && event.value != "" && event.oldValue != event.value) {
					setTimeout(function() {
						   AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "업무레벨이 중복됩니다.");
					}, 1);
					return "";
				} else {
					if (event.value == "") {
						return event.oldValue;							
					}
				}
			}
			
// 			var fieldArr = event.dataField.split("_");
// 			var preCheckRow = "";
// 			var afterCheckRow = "";
// 			if(fieldArr[0] == "grade") {
// 				var engArr = ["a", "b", "c", "d", "e", "f", "g", "h"];
// 				for(var i = 0; i < engArr.length; i++) {
// 					if(engArr[i] == fieldArr[1]) {
// 						preCheckRow = "grade_" + engArr[i-1];
// 						afterCheckRow = "grade_" + engArr[i+1];
// 					}
// 				}
				
				// 첫 번째 컬럼이 아닐 때
// 				if(preCheckRow != engArr[0]) {
// 					if(event.item[preCheckRow] >= event.value) {
// 	 					setTimeout(function() {
// 						   AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "이전 단계보다 높은 값을 입력해야합니다.");
// 						}, 1);
// 						return event.oldValue > event.item[preCheckRow] ? event.oldValue : event.item[preCheckRow]+1; 
// 					}
// 				}

				// 마지막 컬럼이 아닐 때
// 				if(afterCheckRow != engArr[engArr.length-1]) {
// 					if(event.item[afterCheckRow] <= event.value) {
// 	 					setTimeout(function() {
// 						   AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "다음 단계보다 낮은 값을 입력해야합니다.");
// 						}, 1);
// 						return event.oldValue; 
// 					}
// 				}
// 			}
		});
		
		AUIGrid.bind(auiGrid, "cellEditEnd", function (event) {
			if(event.dataField != "maker_hr_svc_cd") {
				var idxes = AUIGrid.getSelectedIndex(auiGrid);
				AUIGrid.setSelectionByIndex(auiGrid, idxes[0], idxes[1]+1); 
			}
		});
	}
	
	function fnAdd() {
// 		var colIndex = AUIGrid.getColumnIndexByDataField(auiGrid, "maker_hr_svc_cd");
// 		fnSetCellFocus(auiGrid, colIndex, "maker_hr_svc_cd");
		var item = new Object();
		if(fnCheckGridEmpty(auiGrid)) {
	    		item.maker_hr_svc_cd = "",
	    		item.grade_a = "",
	    		item.grade_b = "",
	    		item.grade_c = "",
	    		item.grade_d = "",
	    		item.grade_e = "",
	    		item.grade_f = "",
	    		item.grade_g = "",
	    		item.grade_h = "",
	    		item.sort_no = "",
	    		item.total_up_grade = "",
	    		item.total_up_salary_amt = "",
	    		item.use_yn = "Y",
	    		AUIGrid.addRow(auiGrid, item, 'last');
		}
	}
	
	// 그리드 빈값 체크
	function fnCheckGridEmpty() {
		return AUIGrid.validateGridData(auiGrid, ["maker_hr_svc_cd", "grade_a", "grade_b", "grade_c", "grade_d", "grade_e"
			, "grade_f", "grade_g", "grade_h"], "필수 항목은 반드시 값을 입력해야합니다.");
	}
	
	function goSave() {
		if(fnCheckGridEmpty(auiGrid) == false) {
			return;
		}
		
// 		var allGridData = AUIGrid.getGridData(auiGrid);		// 전체 데이터
// 		console.log("allGridData : ", allGridData);
		
// 		var engArr = ["grade_a", "grade_b", "grade_c", "grade_d", "grade_e", "grade_f", "grade_g", "grade_h"];
// 		for(var i = 0; i < allGridData.length; i++) {
// 			for(var j = 0; j < i; j++) {
// 				if(allGridData[i].engArr[j] == allGridData[i].engArr[j+1]) {
// 					alert("단계 값이 맞지 않습니다. 확인 후 다시 시도해주세요.");
// 					return false;
// 				} 
// 			}
// 		}
// 		return false;
		
		var addGridData = AUIGrid.getAddedRowItems(auiGrid);  // 추가내역
		var changeGridData = AUIGrid.getEditedRowItems(auiGrid); // 변경내역
		
// 		if (changeGridData.length == 0 && addGridData.length == 0) {
// 			alert("변경내역이 없습니다.");
// 			return;
// 		}
		
		var makerHrSvcCdArr = [];
		var gradeAArr = [];
		var gradeBArr = [];
		var gradeCArr = [];
		var gradeDArr = [];
		var gradeEArr = [];
		var gradeFArr = [];
		var gradeGArr = [];
		var gradeHArr = [];
		var sortNoArr = [];
		var totalUpGradeArr = [];
		var totalUpSalaryAmtArr = [];
		var useYnArr = [];
		var cmdArr = [];
		
		for (var i = 0; i < addGridData.length; i++) {
			makerHrSvcCdArr.push(addGridData[i].maker_hr_svc_cd);
			gradeAArr.push(addGridData[i].grade_a);
			gradeBArr.push(addGridData[i].grade_b);
			gradeCArr.push(addGridData[i].grade_c);
			gradeDArr.push(addGridData[i].grade_d);
			gradeEArr.push(addGridData[i].grade_e);
			gradeFArr.push(addGridData[i].grade_f);
			gradeGArr.push(addGridData[i].grade_g);
			gradeHArr.push(addGridData[i].grade_h);
			sortNoArr.push(addGridData[i].sort_no);
			totalUpGradeArr.push(addGridData[i].total_up_grade);
			totalUpSalaryAmtArr.push(addGridData[i].total_up_salary_amt);
			useYnArr.push(addGridData[i].use_yn);
			cmdArr.push("C");
		}
		
		for (var i = 0; i < changeGridData.length; i++) {
			makerHrSvcCdArr.push(changeGridData[i].maker_hr_svc_cd);
			gradeAArr.push(changeGridData[i].grade_a);
			gradeBArr.push(changeGridData[i].grade_b);
			gradeCArr.push(changeGridData[i].grade_c);
			gradeDArr.push(changeGridData[i].grade_d);
			gradeEArr.push(changeGridData[i].grade_e);
			gradeFArr.push(changeGridData[i].grade_f);
			gradeGArr.push(changeGridData[i].grade_g);
			gradeHArr.push(changeGridData[i].grade_h);
			sortNoArr.push(changeGridData[i].sort_no);
			totalUpGradeArr.push(changeGridData[i].total_up_grade);
			totalUpSalaryAmtArr.push(changeGridData[i].total_up_salary_amt);
			useYnArr.push(changeGridData[i].use_yn);
			cmdArr.push("U");
		}
		
		var option = {
				isEmpty : true
		};
		
		var param = {
				maker_hr_svc_cd_str : $M.getArrStr(makerHrSvcCdArr, option),
				grade_a_str : $M.getArrStr(gradeAArr, option),
				grade_b_str : $M.getArrStr(gradeBArr, option),
				grade_c_str : $M.getArrStr(gradeCArr, option),
				grade_d_str : $M.getArrStr(gradeDArr, option),
				grade_e_str : $M.getArrStr(gradeEArr, option),
				grade_f_str : $M.getArrStr(gradeFArr, option),
				grade_g_str : $M.getArrStr(gradeGArr, option),
				grade_h_str : $M.getArrStr(gradeHArr, option),
				sort_no_str : $M.getArrStr(sortNoArr, option),
				total_up_grade_str : $M.getArrStr(totalUpGradeArr, option),
				total_up_salary_amt_str : $M.getArrStr(totalUpSalaryAmtArr, option),
				use_yn_str : $M.getArrStr(useYnArr, option),
				cmd_str : $M.getArrStr(cmdArr, option),
				group_code : "PROP",
				code : 'HR_SVC_IMG_SEQ',
				code_name : '인사서비스이미지파일번호',
				code_v1 : fileSeq,
		}
		
		console.log(param);
		
		$M.goNextPageAjaxSave("/comm/comm012004/save", $M.toGetParam(param) , {method : 'POST'},
			function(result) {
	    		if(result.success) {
	    			alert("저장이 완료되었습니다.");
	    			goSearch();
				}
			}
		);
	}
	
	function goSearch() {
		var param = {
			s_maker_hr_svc_cd : $M.getValue("s_maker_hr_svc_cd")
		};
			
		$M.goNextPageAjax("/comm/comm012004/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					$("#total_cnt").html(result.total_cnt);
					AUIGrid.setGridData(auiGrid, result.list);
					
					console.log(result);
					$(".hr_file_" + fileIndex).remove();
					setFileInfo(result);
				};
			}		
		);	
	}
	
	// 엔터키 이벤트
	function enter(fieldObj) {
		var field = ["s_maker_hr_svc_cd"];
		$.each(field, function() {
			if(fieldObj.name == this) {
				goSearch();
			};
		});
	}
	
	function goSearchFile() {
		if($("input[name='file_seq']").size() >= fileCount) {
			alert("파일은 " + fileCount + "개만 첨부하실 수 있습니다.");
			return false;
		}
		
		var param = {
			upload_type	: "SERVICE",
			file_type : "both",
		};
		
		openFileUploadPanel('setFileInfo', $M.toGetParam(param));
	}
	
	function setFileInfo(result) {
		fileSeq = result.file_seq;
		if (fileSeq != "" && fileSeq != 0 && fileSeq != undefined) {
			var str = ''; 
			str += '<div class="hr_file_' + fileIndex + '" style="float:left; display:block;">';
			str += '<a href="javascript:fileDownload(' + result.file_seq + ');" style="color: blue;">' + result.file_name + '</a>&nbsp;';
			str += '<input type="hidden" name="file_seq" value="' + result.file_seq + '"/>';
			str += '<button type="button" style="min-width:20px;" class="btn-default" onclick="javascript:fnRemoveFile(' + fileIndex + ', ' + result.file_seq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
			str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
			str += '</div>';
			$('.hr_file_div').append(str);
// 			fileIndex++;
		}
	}
	
	// 첨부파일 삭제
	function fnRemoveFile(fileIndex, fileSeq) {
		var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
		if (result) {
			$(".hr_file_" + fileIndex).remove();
			fileSeq = "";
		} else {
			return false;
		}
	}
	</script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
<!-- contents 전체 영역 -->
		<div class="content-box">
			<div class="contents">

<!-- 메인 타이틀 -->
<!-- 검색영역 -->		
					<div class="search-wrap mt10">
						<table class="table">
							<colgroup>
								<col width="50px">
								<col width="150px">
								<col width="*">
							</colgroup>
							<tbody>
								<tr>								
									<th>메이커명</th>
									<td>
										<input type="text" class="form-control" id="s_maker_hr_svc_cd" name="s_maker_hr_svc_cd">
									</td>		
									<td class="">
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()">조회</button>
									</td>
								</tr>				
							</tbody>
						</table>
					</div>
<!-- /검색영역 -->
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<div class="btn-group">
							<h4>조회결과</h4>
							<div class="hr_file_div">
								<div class="table-attfile" style="float:left">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
								&nbsp;&nbsp;
								</div>
							</div>						
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->					

					<div id="auiGrid" style="margin-top: 5px; height: 440px;"></div>

<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>			
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>									
					</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>
			</div>
<!-- /contents 전체 영역 -->		
</form>
</body>
</html>