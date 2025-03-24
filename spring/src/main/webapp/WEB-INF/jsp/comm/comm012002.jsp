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
	
	var gradeJson = JSON.parse('${codeMapJsonObj['GRADE']}');
	
// 	var jobGradeList = [
// 		{"code_value" : "09", "code_name" : "직장"}, {"code_value" : "08", "code_name" : "매니저"}
// 	]
	
	var bizGradeHmbList = [
		{"code_value" : "H", "code_name" : "상"}, {"code_value" : "M", "code_name" : "중"}, {"code_value" : "B", "code_name" : "하"}
	]
	
	var defaultArr= { "code_name" : "- 선택 -","code_value":"0" };	
	bizGradeHmbList.unshift(defaultArr);
	
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
			showStateColumn : true
		};
		
		var columnLayout = [
			{
				dataField : "hr_job_seq",
				visible : false
			},
			{
				headerText : "직책",
				dataField : "grade_cd",
				width : "80",
				style : "aui-center aui-editable",
				editable : true,
// 				filter : {
// 					showIcon : true
// 				},
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : false,
					showEditorBtnOver : false,
					list : gradeJson,
					keyField : "code_value", 
					valueField : "code_name" 				
				},
				labelFunction : function(rowIndex, columnIndex, value){
					for(var i=0; i<gradeJson.length; i++){
						if(value == gradeJson[i].code_value){
							return gradeJson[i].code_name;
						}
					}
					return value;
				}
			},
			{
				headerText : "레벨",
				dataField : "biz_code",
				width : "80",
				style : "aui-center aui-editable",
				editable : true,
				filter : {
					showIcon : true
				},
				editRenderer : {
				      type : "InputEditRenderer",
				      maxlength : 4,
				      // 에디팅 유효성 검사
				      validator : AUIGrid.commonValidator
				},
			},
			{
				headerText : "등급",
				dataField : "biz_grade_hmb",
				width : "80",
				style : "aui-center aui-editable",
				editable : true,
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : false,
					showEditorBtnOver : false,
					list : bizGradeHmbList,
					keyField : "code_value", 
					valueField : "code_name" 				
				},
				labelFunction : function(rowIndex, columnIndex, value){
					var retStr = value;
					for(var i=0; i<bizGradeHmbList.length; i++){
						if(bizGradeHmbList[i].code_value == value) {
							retStr = bizGradeHmbList[i].code_name;
							break;
						} else if(value == null) {
							retStr = "- 선택 -";
							break;
						}
					}

					return retStr;
				},
			},
			{
				headerText : "월 수당",
				dataField : "mon_benefit_amt",
				width : "130",
				style : "aui-right aui-editable",
				dataType : "numeric",
				editRenderer : {
				      type : "InputEditRenderer",
				      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
				},
				editable : true,
			},
			{
				headerText : "연 수당",
				dataField : "year_benefit_amt",
				width : "150",
				style : "aui-right",
				dataType : "numeric",
				editable : false,
				expFunction : function(  rowIndex, columnIndex, item, dataField ) { 
					// 수량 * 단가 계산
// 					var val = 0;
					
// 					if (item.biz_code == "SA2" || item.biz_code == "M2") {
// 						val = ( item.mon_benefit_amt * 24 );
// 					} else {
// 						val = ( item.mon_benefit_amt * 12 ); 
// 					}
					
					return  item.mon_benefit_amt * 12;
				}
			},
			{
				headerText : "내용",
				dataField : "remark",
				width : "450",
				style : "aui-left aui-editable",
				editable : true,
			},
			{
				headerText : "정렬순서",
				dataField : "sort_no",
				width : "80", 
				style : "aui-center aui-editable",
				editable : true,
			},
			{
				headerText : "사용여부",
				dataField : "use_yn",
				width : "80",
				style : "aui-center",
				renderer : {
					type : "CheckBoxEditRenderer",
					editable : true,
					checkValue : "Y",
					unCheckValue : "N"
				},
				filter : {
					showIcon : true
				}
			},
		];
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros)
		AUIGrid.setGridData(auiGrid, []);
		
		AUIGrid.bind(auiGrid, "cellEditBegin", function (event) {
// 			if (event.dataField == "biz_grade_hmb") {
// 				if (event.item.job_cd != "08") {
// 					return false;
// 				}
// 			}
			
// 			if(event.dataField == "job_cd" || event.dataField == "biz_code" || event.dataField == "biz_grade_hmb") {
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
		
// 		AUIGrid.bind(auiGrid, "cellEditEnd", function (event) {
// 			if(event.dataField == "job_cd" || event.dataField == "biz_code" || event.dataField == "biz_grade_hmb") {
// 				if (event.dataField == "job_cd") {
// 					if (event.item.job_cd == "09") {
// 						AUIGrid.updateRow(auiGrid, {"biz_grade_hmb" : "0"}, event.rowIndex);
// 					}
// 				}

// 				var nowVal = "";
// 				if (event.item.job_cd == "08") {
// 					nowVal = event.item.job_cd + '#' + event.item.biz_code + '#' + event.item.biz_grade_hmb;
// 				} else {
// 					nowVal = event.item.job_cd + '#' + event.item.biz_code;
// 				}
				
// 				var nowRowId = event.rowIndex; 
// 				var gridData = AUIGrid.getGridData(auiGrid);
				
// 				for (var i = 0 ; i < gridData.length; i++) {
// 					if (nowRowId != i) {
						
// 						var itemPk = "";
// 						if (event.item.job_cd == "08") {
// 							itemPk = gridData[i].job_cd + '#' + gridData[i].biz_code + '#' + gridData[i].biz_grade_hmb;
// 						} else {
// 							itemPk = gridData[i].job_cd + '#' + gridData[i].biz_code;
// 						}
						
// 						if (itemPk == nowVal) {
// 							AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "기준, 레벨, 등급이 중복됩니다.");
							
// 							if(event.dataField == "job_cd") {
// 								AUIGrid.updateRow(auiGrid, {"job_cd" : event.oldValue}, event.rowIndex);
								
// 								if (event.item.job_cd == "09") {
// 									AUIGrid.updateRow(auiGrid, {"biz_grade_hmb" : event.item.biz_grade_hmb}, event.rowIndex);
// 								}
// 							} else if (event.dataField == "biz_code" ) {
// 								AUIGrid.updateRow(auiGrid, {"biz_code" : event.oldValue}, event.rowIndex);		
// 							} else {
// 								AUIGrid.updateRow(auiGrid, {"biz_grade_hmb" : event.oldValue}, event.rowIndex);		
// 							}
// 						}
// 					}
// 				}
// 			}
// 		});
	}
	
	function fnAdd() {
		var item = new Object();
		if(fnCheckGridEmpty(auiGrid)) {
	    		item.hr_job_seq = 0,
	    		item.job_cd = "",
	    		item.biz_code = "",
	    		item.mon_benefit_amt = "",
	    		item.year_benefit_amt = "",
	    		item.biz_grade_hmb = "0",
	    		item.remark = "",
	    		item.sort_no = "",
	    		item.use_yn = "Y",
	    		AUIGrid.addRow(auiGrid, item, 'last');
		}
	}
	
	// 그리드 빈값 체크
	function fnCheckGridEmpty() {
		return AUIGrid.validateGridData(auiGrid, ["grade_cd", "biz_code", "biz_grade_hmb", "mon_benefit_amt", "sort_no"], "필수 항목은 반드시 값을 입력해야합니다.");
	}
	
	function goSave() {
		if(fnCheckGridEmpty(auiGrid) == false) {
			return;
		}
		
		var addGridData = AUIGrid.getAddedRowItems(auiGrid);  // 추가내역
		var changeGridData = AUIGrid.getEditedRowItems(auiGrid); // 변경내역
		
		if (changeGridData.length == 0 && addGridData.length == 0) {
			alert("변경내역이 없습니다.");
			return;
		}
		
		var hrJobSeqArr = [];
		var gradeCdArr = [];
		var bizCodeArr = [];
		var monBenefitAmtArr = [];
		var bizGradeHmbArr = [];
		var remarkArr = [];
		var sortNoArr = [];
		var useYnArr = [];
		var cmdArr = [];
		
		for (var i = 0; i < addGridData.length; i++) {
			hrJobSeqArr.push(addGridData[i].hr_job_seq);
			gradeCdArr.push(addGridData[i].grade_cd);
			bizCodeArr.push(addGridData[i].biz_code);
			monBenefitAmtArr.push(addGridData[i].mon_benefit_amt);
			bizGradeHmbArr.push(addGridData[i].biz_grade_hmb);
			remarkArr.push(addGridData[i].remark);
			sortNoArr.push(addGridData[i].sort_no);
			useYnArr.push(addGridData[i].use_yn);
			cmdArr.push("C");
		}
		
		for (var i = 0; i < changeGridData.length; i++) {
			hrJobSeqArr.push(changeGridData[i].hr_job_seq);
			gradeCdArr.push(changeGridData[i].grade_cd);
			bizCodeArr.push(changeGridData[i].biz_code);
			monBenefitAmtArr.push(changeGridData[i].mon_benefit_amt);
			bizGradeHmbArr.push(changeGridData[i].biz_grade_hmb);
			remarkArr.push(changeGridData[i].remark);
			sortNoArr.push(changeGridData[i].sort_no);
			useYnArr.push(changeGridData[i].use_yn);
			cmdArr.push("U");
		}
		
		var option = {
				isEmpty : true
		};
		
		var param = {
				hr_job_seq_str : $M.getArrStr(hrJobSeqArr, option),
				grade_cd_str : $M.getArrStr(gradeCdArr, option),
				biz_code_str : $M.getArrStr(bizCodeArr, option),
				mon_benefit_amt_str : $M.getArrStr(monBenefitAmtArr, option),
				biz_grade_hmb_str : $M.getArrStr(bizGradeHmbArr, option),
				remark_str : $M.getArrStr(remarkArr, option),
				sort_no_str : $M.getArrStr(sortNoArr, option),
				use_yn_str : $M.getArrStr(useYnArr, option),
				cmd_str : $M.getArrStr(cmdArr, option),
		}
		
		$M.goNextPageAjaxSave("/comm/comm012002/save", $M.toGetParam(param) , {method : 'POST'},
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
			s_biz_code : $M.getValue("s_biz_code")
		};
			
		$M.goNextPageAjax("/comm/comm012002/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					$("#total_cnt").html(result.total_cnt);
					AUIGrid.setGridData(auiGrid, result.list);
				};
			}		
		);	
	}
	
	// 엔터키 이벤트
	function enter(fieldObj) {
		var field = ["s_biz_code"];
		$.each(field, function() {
			if(fieldObj.name == this) {
				goSearch();
			};
		});
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
									<th>코드명</th>
									<td>
										<input type="text" class="form-control" id="s_biz_code" name="s_biz_code">
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
							<div>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->					

					<div id="auiGrid" style="margin-top: 5px; height: 440px;" ></div>

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