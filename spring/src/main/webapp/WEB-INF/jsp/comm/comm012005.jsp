<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 인사코드관리 > 기본 > null
-- 작성자 : 김경빈
-- 최초 작성일 : 2024-04-25 13:32:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
<script type="text/javascript">

	var auiGrid;
	var maxLevel;
	var codePrefix = "${prefix}";
	var orgCodeList = ${orgList};
	
	$(document).ready(function() {
		createAUIGrid();
		goSearch();
	});

	// 그리드 생성
	function createAUIGrid() {
		var gridPros = {
			editable : true,
			rowIdField : "_$uid",
			wrapSelectionMove : false,
			enableSorting : true,
			showRowNumColumn: true,
			enableFilter :true,
			showStateColumn : true,
		};
		
		var columnLayout = [
			{
				headerText : "코드",
				dataField : "biz_code",
				width : "100",
				style : "aui-center",
				editable : false,
				editRenderer : {
					type : "InputEditRenderer",
					maxlength : 4,
					// 에디팅 유효성 검사
					validator : AUIGrid.commonValidator
				},
			},
			{
				headerText : "기본(급여)",
				dataField : "salary_amt",
				width : "150",
				style : "aui-right aui-editable",
				dataType : "numeric",
				editRenderer : {
					type : "InputEditRenderer",
					onlyNumeric : true, // Input 에서 숫자만 가능케 설정
				},
				editable : true,
			},
			{
				// 수정되지 않은 기본 급여 원본
				dataField: "salary_amt_origin",
				visible: false,
			},
			{
				headerText : "권한 별 시작레벨",
				dataField : "org_code_arr",
				style : "aui-left",
				editRenderer : {
					showEditorBtnOver : true, // 마우스 오버 시 에디터버턴 보이기
					type : "DropDownListRenderer",
					keyField : 'org_code',
					valueField : 'path_org_name',
					list : orgCodeList,
					required : true,
					multipleMode : true,
					delimiter: ", ", // 다중 선택시 구분자
					listAlign : "left", // 왼쪽정렬
				},
				labelFunction : function(rowIndex, columnIndex, value) {
					if (value != null && value != "") {
						var delimiter = ", ";
						var valueArr = value.split(delimiter);
						var tempValueArr = [];
						for (var i=0; i<orgCodeList.length; i++){
							if (valueArr.includes(orgCodeList[i]["org_code"])) {
								var pathOrgNameArr = orgCodeList[i]["path_org_name"].split(" > ").slice(1);
								var orgName = pathOrgNameArr.join(" > ");
								tempValueArr.push(orgName);
							}
						}
						return tempValueArr.sort().join(delimiter);
					} else {
						return "";
					}
				}
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
				width : "80",
				style : "aui-center",
				renderer : {
					type : "CheckBoxEditRenderer",
					editable : true,
					checkValue : "Y",
					unCheckValue : "N"
				},
			},
			{
				// 상승률
				dataField : "avg_up_salary_rate",
				visible : false
			},
		];
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, []);
	}

	// 조회
	function goSearch() {
		var param = {
			s_biz_code : $M.getValue("s_biz_code")
		};

		$M.goNextPageAjax("/comm/comm012005/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					AUIGrid.setGridData(auiGrid, result.list);
					$("#total_cnt").html(result.total_cnt);
					$M.setValue("rate", result.avg_up_salary_rate); // 상승률
					maxLevel = getMaxLevel();
				}
			}
		);
	}

	// 그리드 필수항목 체크
	function fnCheckGridEmpty() {
		return AUIGrid.validateGridData(auiGrid, ["biz_code", "salary_amt", "sort_no"], "필수 항목은 반드시 값을 입력해야합니다.");
	}

	// 행 추가 이벤트
	function fnAdd() {
		var item = {};
		maxLevel = getMaxLevel();
		if (fnCheckGridEmpty(auiGrid)) {
    		item.biz_code = codePrefix + maxLevel;
    		item.salary_amt = "";
    		item.sort_no = maxLevel;
    		item.use_yn = "Y";
    		AUIGrid.addRow(auiGrid, item, 'last');
			maxLevel++;
		} else {
			alert("필수 항목은 반드시 값을 입력해야합니다.");
		}
	}

	// 저장 이벤트
	function goSave() {
		if (fnCheckGridEmpty(auiGrid) == false) {
			return;
		}
		
		var addGridData = AUIGrid.getAddedRowItems(auiGrid);  // 추가내역
		var changeGridData = AUIGrid.getEditedRowItems(auiGrid); // 변경내역
		
		if (changeGridData.length == 0 && addGridData.length == 0) {
			alert("변경내역이 없습니다.");
			return;
		}

		// 권한 별 시작레벨 중복 체크
		var orgArr = AUIGrid.getGridData(auiGrid)
				.filter(m => m.use_yn === 'Y')
				.map(m => m.org_code_arr)
				.filter(str => str) // filter empty string
				.map(str => str.split(", "))
				.flat();
		let hasDuplicate = orgArr.length !== new Set(orgArr).size;
		if (hasDuplicate) {
			alert("권한 별 시작레벨은 중복될 수 없습니다.");
			return;
		}
		
		var bizCodeArr = [];
		var salaryAmtArr = [];
		var sortNoArr = [];
		var avgUpSalaryAmtArr = [];
		var avgUpSalaryRateArr = [];
		var useYnArr = [];
		var cmdArr = [];
        var orgCodeArr = []; // 권한 별 시작레벨, 빈칸인 경우 ' ' 으로 대체

        addGridData.forEach(data => {
			bizCodeArr.push(data.biz_code);
			salaryAmtArr.push(data.salary_amt);
			sortNoArr.push(data.sort_no);
			useYnArr.push(data.use_yn);
			avgUpSalaryRateArr.push(data.avg_up_salary_rate);
            orgCodeArr.push(data.org_code_arr ? data.org_code_arr : " ");
			cmdArr.push("C");
        });

        changeGridData.forEach(data => {
			bizCodeArr.push(data.biz_code);
			salaryAmtArr.push(data.salary_amt);
			sortNoArr.push(data.sort_no);
			useYnArr.push(data.use_yn);
			avgUpSalaryRateArr.push(data.avg_up_salary_rate);
            orgCodeArr.push(data.org_code_arr ? data.org_code_arr : " ");
			cmdArr.push("U");
        });

		var option = {
			isEmpty : true // 빈값 허용
		};
		
		var param = {
			biz_code_str : $M.getArrStr(bizCodeArr, option),
			salary_amt_str : $M.getArrStr(salaryAmtArr, option),
			sort_no_str : $M.getArrStr(sortNoArr, option),
			use_yn_str : $M.getArrStr(useYnArr, option),
			avg_up_salary_rate_str : $M.getArrStr(avgUpSalaryRateArr, option),
            org_code_str : $M.getArrStr(orgCodeArr, option),
			cmd_str : $M.getArrStr(cmdArr, option),
		};

		$M.goNextPageAjaxSave("/comm/comm012005/save", $M.toGetParam(param) , {method : 'POST'},
			function(result) {
	    		if (result.success) {
	    			alert("저장이 완료되었습니다.");
	    			goSearch();
				}
			}
		);
	}
	
	// 엔터키 바인딩
	function enter(fieldObj) {
		var field = ["s_biz_code"];
		$.each(field, function() {
			if (fieldObj.name == this) {
				goSearch();
			}
		});
	}
	
	// 적용
	function goApply() {
		var rate = Number($M.getValue("rate")) / 100; // 상승률
		
		if (rate == "" || rate == "0" || rate == "0.0") {
			alert("상승률을 입력해주세요.");
			return;
		}
		
		var gridData = AUIGrid.getGridData(auiGrid);
		for (var i = 0; i < gridData.length; i++) {
			var data = AUIGrid.getGridData(auiGrid);
			var salaryAmt = Number(data[i].salary_amt_origin);
			AUIGrid.updateRow(auiGrid, { "salary_amt" : salaryAmt + (rate * salaryAmt) }, i);
			AUIGrid.updateRow(auiGrid, { "avg_up_salary_rate" : $M.getValue("rate") }, i);
		}
	}

	// 그리드의 코드 값을 기준으로 최대 값을 구한다
	function getMaxLevel() {
		var sortingData = AUIGrid.getGridData(auiGrid)
				.map(data => data.biz_code.substring(2))
				.sort((a, b) => b - a);
		return parseInt(sortingData && sortingData[0] ? sortingData[0] : 0) + 1;
	}
</script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
	<!-- contents 전체 영역 -->
	<div class="content-box">
		<div class="contents">
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
								<button type="button" class="btn btn-important" style="width: 50px;" onclick="goSearch()">조회</button>
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
						<span class="ml5">상승률</span>
						<input type="text" style="width: 120px; text-align: right;" id="rate" name="rate" format="decimal4">
						<span class="mr5">%</span>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
					</div>
				</div>
			</div>
			<!-- /그리드 타이틀, 컨트롤 영역 -->
			<div id="auiGrid" style="margin-top: 5px; height: 440px;" ></div>
			<!-- 하단 영역 -->
			<div class="btn-group mt5">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
			<!-- /하단 영역 -->
		</div>
	</div>
</form>
</body>
</html>