<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 인사코드관리 > null > 능력
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-04-12 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var jobGrpList;
	var maxLevel;
	
	$(document).ready(function () {
		// 그리드 생성
		createAUIGrid();
		goSearch();
		
	});
	
	function createAUIGrid() {
		var gridPros = {
			editable : true,
			rowIdField : "_$uid",
// 			rowIdTrustMode : true,
			wrapSelectionMove : false,
			enableSorting : true,
			showRowNumColumn: true,
			enableFilter :true,
			showStateColumn : true
		};
		
		var columnLayout = []
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros)
		AUIGrid.setGridData(auiGrid, []);
		
		AUIGrid.bind(auiGrid, "cellEditBegin", function (event) {
			if(event.dataField == "biz_level") {
				// 추가된 행 아이템인지 조사하여 추가된 행인 경우만 에디팅 진입 허용
				if(AUIGrid.isAddedById(event.pid, event.item._$uid)) {
					return true;
				} else {
					setTimeout(function() {
						   AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "새로 추가된 행만 수정이 가능합니다.");
					}, 1);
					return false; // false 반환하면 기본 행위 안함(즉, cellEditBegin 의 기본행위는 에디팅 진입임)
				}
			}
			return true;
		});
		
		AUIGrid.bind(auiGrid, "cellEditEndBefore", function (event) {
			if(event.dataField == "biz_level") {
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
		});
		
	}
	
	function fnAdd() {
		var item = new Object();
		if(fnCheckGridEmpty(auiGrid)) {
			item.biz_level = maxLevel,
    		item.biz_code = "LA"+maxLevel,
    		item.salary_amt = "",
    		item.sort_no = maxLevel,
    		item.use_yn = "Y",
    		AUIGrid.addRow(auiGrid, item, 'last');

			maxLevel++;
		}
	}
	
	// 그리드 빈값 체크
	function fnCheckGridEmpty() {
		return AUIGrid.validateGridData(auiGrid, ["biz_level", "biz_code", "salary_amt", "sort_no"], "필수 항목은 반드시 값을 입력해야합니다.");
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
		
		var bizLevelArr = [];
		var bizCodeArr = [];
		var salaryAmtArr = [];
		var sortNoArr = [];
		var useYnArr = [];
		var avgUpSalaryAmtArr = [];
		var avgUpSalaryRateArr = [];
		var useYnArr = [];
		var cmdArr = [];
		
		var jobGrpCdArr = [];
		
		for (var i = 0; i < addGridData.length; i++) {
			bizLevelArr.push(addGridData[i].biz_level);
			bizCodeArr.push(addGridData[i].biz_code);
			salaryAmtArr.push(addGridData[i].salary_amt);
			sortNoArr.push(addGridData[i].sort_no);
			useYnArr.push(addGridData[i].use_yn);
			avgUpSalaryAmtArr.push(addGridData[i].avg_up_salary_amt);
			avgUpSalaryRateArr.push(addGridData[i].avg_up_salary_rate);
			cmdArr.push("C");
		}
		
		for (var i = 0; i < changeGridData.length; i++) {
			bizLevelArr.push(changeGridData[i].biz_level);
			bizCodeArr.push(changeGridData[i].biz_code);
			salaryAmtArr.push(changeGridData[i].salary_amt);
			sortNoArr.push(changeGridData[i].sort_no);
			useYnArr.push(changeGridData[i].use_yn);
			avgUpSalaryAmtArr.push(changeGridData[i].avg_up_salary_amt);
			avgUpSalaryRateArr.push(changeGridData[i].avg_up_salary_rate);
			cmdArr.push("U");
		}
		
		var option = {
				isEmpty : true
		};
		
		var param = {
				biz_level_str : $M.getArrStr(bizLevelArr, option),
				biz_code_str : $M.getArrStr(bizCodeArr, option),
				salary_amt_str : $M.getArrStr(salaryAmtArr, option),
				sort_no_str : $M.getArrStr(sortNoArr, option),
				use_yn_str : $M.getArrStr(useYnArr, option),
				avg_up_salary_amt_str : $M.getArrStr(avgUpSalaryAmtArr, option),
				avg_up_salary_rate_str : $M.getArrStr(avgUpSalaryRateArr, option),
				cmd_str : $M.getArrStr(cmdArr, option),
		}
		
		console.log(param);
		
		$M.goNextPageAjaxSave("/comm/comm012001/save", $M.toGetParam(param) , {method : 'POST'},
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
			
		$M.goNextPageAjax("/comm/comm012001/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					fnResult(result);
					maxLevel = result.maxLevel;
				};
			}		
		);	
	}
	
	function fnResult(result) {
		if (result.success) {
			var columnLayout = [
				{
					dataField : "origin_salary_amt",
					visible : false
				},
				{
					dataField : "avg_up_salary_amt",
					visible : false
				},
				{
					dataField : "avg_up_salary_rate",
					visible : false
				},
				{
					headerText : "업무레벨",
					dataField : "biz_level",
					width : "100",
					style : "aui-center",
					editable : false,
					editRenderer : {
					      type : "InputEditRenderer",
					      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
					},
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "코드",
					dataField : "biz_code",
					width : "100",
					style : "aui-center",
					editable : false,
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
					headerText : "급여",
					dataField : "salary_amt",
					width : "200",
					style : "aui-right aui-editable",
					dataType : "numeric",
					editRenderer : {
					      type : "InputEditRenderer",
					      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
					},
					editable : true,
				},
				{
					headerText : "정렬순서",
					dataField : "sort_no",
					width : "70",
					style : "aui-center",
					dataType : "numeric",
					editRenderer : {
					      type : "InputEditRenderer",
					      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
					},
					editable : false,
				},
				{
					headerText : "사용여부",
					dataField : "use_yn",
					width : "70",
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
				}
			];
			
			$("#total_cnt").html(result.total_cnt);
			
			$M.setValue("avg_up_salary", result.list[0].avg_up_salary_amt);
			$M.setValue("rate", result.list[0].avg_up_salary_rate);
			
			var jobCodeList = result.jobCodeList;
			jobGrpList = result.jobCodeList;
			var columnObjArr = [];
			
			for (var i = 0; i < jobCodeList.length; i++) {
				var columnObj = {
						headerText : jobCodeList[i].code_name,
						dataField : jobCodeList[i].header_seq,
						width : "12%",
						renderer : {
							type : "CheckBoxEditRenderer",
							editable : false,
							checkValue : "Y",
							unCheckValue : "N"
						},
				}
				columnObjArr.push(columnObj);
			}
			
			AUIGrid.changeColumnLayout(auiGrid, columnLayout);
			AUIGrid.addColumn(auiGrid, columnObjArr, 8);
			AUIGrid.setGridData(auiGrid, result.list);
			
			// 에디팅 정상 종료 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellClick", function (event) {
				console.log(event);
				
				if (event.dataField.startsWith("job_grp_")) {
					setTimeout(function() {
						   AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "직군별 레벨설정은 [직군관리 버튼> 그룹설정 버튼] 에서 진행 바랍니다.");
					}, 1);
				}
			});
		}
	}
	
	// 엔터키 이벤트
// 	function enter(fieldObj) {
// 		var field = ["s_biz_code"];
// 		$.each(field, function() {
// 			if(fieldObj.name == this) {
// 				goSearch();
// 			};
// 		});
// 	}
	
	// 적용
	function goApply() {
		var avgUpSalary = $M.getValue("avg_up_salary"); // 평균 상승 연봉
		var rate = $M.getValue("rate"); // 상승률
		
		if ((avgUpSalary == "0" || avgUpSalary == "") && (rate == "" || rate == "0" || rate == "0.0")) {
			alert("평균 상승 연봉 또는 상승률을 입력해주세요.");
			return;
		}
		
		var gridData = AUIGrid.getGridData(auiGrid);
		for (var i = 0; i < gridData.length; i++) {
			var data = AUIGrid.getGridData(auiGrid);
			AUIGrid.updateRow(auiGrid, { "salary_amt" : data[i].salary_amt + Number(avgUpSalary) }, i+1);
			AUIGrid.updateRow(auiGrid, { "avg_up_salary_amt" : Number(avgUpSalary) }, i);
			AUIGrid.updateRow(auiGrid, { "avg_up_salary_rate" : rate }, i);
		}
	}
	
	function fnChangeAmt(str) {
		var gridData = AUIGrid.getGridData(auiGrid);
		var avgUpSalary = $M.getValue("avg_up_salary"); // 평균 상승 연봉
		var rate = $M.getValue("rate"); // 상승률

		if (str == "rate") {
			// 100단위 절상을 위해 100 * 1000으로 나누고 올림한 뒤에 다시 1000을 곱해서 변경
			var avgUpVal = Math.ceil(gridData[0].salary_amt * rate / 100000) * 1000;  // 기준급여의 상승률만큼의 평균상승연봉금액
			$M.setValue("avg_up_salary", avgUpVal); // 평균 상승 연봉 세팅
		} else {
			var rateVal = Number(avgUpSalary) / gridData[0].salary_amt * 100;  // 기준급여의 평균상승연봉만큼의 상승률
			$M.setValue("rate", rateVal.toFixed(1)); // 상승률 세팅
		}
	}
	
	// 직군관리
	function fnJobGroupDetail() {
		var param = {
				
		}
		var popupOption = "";
		$M.goNextPage('/comm/comm0120p01', $M.toGetParam(param), {popupStatus : popupOption});
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
<!-- 									<th>코드명</th> -->
<!-- 									<td> -->
<!-- 										<input type="text" class="form-control" id="s_biz_code" name="s_biz_code"> -->
<!-- 									</td>		 -->
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
						<div class="left text-warning ml5">
							※ 직군별 레벨범위 설정은 [직군관리 버튼 > 그룹설정 버튼] 에서 진행 해 주시기 바랍니다.
						</div>
							<div>
								평균 상승 연봉 <input type="text" style="width: 120px; text-align: right;" id="avg_up_salary" name="avg_up_salary" format="num" onchange="javascript:fnChangeAmt('amt');">
<%-- 								평균 상승 연봉 <input type="text" style="width: 120px; text-align: right;" id="avg_up_salary_amt" name="avg_up_salary_amt" format="num" value="${avg_up_salary_amt}"> --%>
							       상승률 <input type="text" style="width: 120px; text-align: right;" id="rate" name="rate" format="decimal4" onchange="javascript:fnChangeAmt('rate');">% 
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
								<button type="button" class="btn btn-info" style="width: 50px;" onclick="javascript:fnJobGroupDetail()">직군관리</button>
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