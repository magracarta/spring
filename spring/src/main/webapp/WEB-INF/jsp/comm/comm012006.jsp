<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 인사코드관리 > 취득 > null
-- 작성자 : 김경빈
-- 최초 작성일 : 2024-04-29 15:01:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
<script type="text/javascript">
	
	var hrAbilityJson = JSON.parse('${codeMapJsonObj['HR_ABILITY']}');
	var avgUpSalaryAmt = "${avgUpSalaryAmt}";
	var orgList = ${orgList};

	$(document).ready(function () {
		createAUIGrid();
		goSearch();

		$M.setValue("avg_up_salary_amt", avgUpSalaryAmt);
	});

	// 엔터키 이벤트 바인딩
	function enter(fieldObj) {
		var field = ["s_ability_name"];
		$.each(field, function() {
			if (fieldObj.name == this) {
				goSearch();
			}
		});
	}

	// 조회
	function goSearch() {
		var param = {
			s_ability_name : $M.getValue("s_ability_name")
		};

		$M.goNextPageAjax("/comm/comm012006/search", $M.toGetParam(param), {method : 'GET'},
			function(result) {
				if (result.success) {
					$("#total_cnt").html(result.total_cnt);
					AUIGrid.setGridData(auiGrid, result.list);
					$M.setValue("avgUpSalaryAmt", result.avgUpSalaryAmt);
				}
			}
		);
	}

	// 그리드 생성
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
				dataField : "hr_code_ability_seq", // PK
				visible : false,
			},
			{
				headerText : "구분",
				dataField : "hr_ability_cd",
				width : "80",
				style : "aui-center aui-editable",
				editable : true,
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : true,
					showEditorBtnOver : true,
					list : hrAbilityJson,
					keyField : "code_value",
					valueField : "code_name"
				},
				labelFunction : function(rowIndex, columnIndex, value) {
					var retStr = value;
					for (var i=0; i<hrAbilityJson.length; i++) {
						if (hrAbilityJson[i].code_value == value) {
							retStr = hrAbilityJson[i].code_name;
							break;
						} else if (value == null) {
							retStr = "선택";
							break;
						}
					}
					return retStr;
				},
			},
			{
				headerText : "부서",
				dataField : "org_code_str",
				width : "200",
				style : "aui-left aui-editable",
				editable : true,
				editRenderer : {
					showEditorBtnOver : true, // 마우스 오버 시 에디터버턴 보이기
					type : "DropDownListRenderer",
					keyField : 'org_code',
					valueField : 'org_name',
					list : orgList,
					required : true,
					multipleMode : true,
					delimiter: "^", // 다중 선택시 구분자
					listAlign : "left", // 왼쪽정렬
				},
				labelFunction : function(rowIndex, columnIndex, value) {
					if (!value) {
						return "";
					}
					var valueArr = value.split("^");
					return orgList
							.filter(obj => valueArr.includes(obj.org_code))
							.map(obj => obj.org_name)
							.join(", ");
				},
			},
			{
				headerText : "수당명",
				dataField : "ability_name",
				width : "350",
				style : "aui-left aui-editable",
				editRenderer : {
					type : "InputEditRenderer",
					maxlength : 40,
				},
				editable : true,
			},
			{
				headerText : "배율",
				dataField : "ability_rate",
				width : "50",
				style : "aui-center aui-editable",
				dataType : "numeric",
				editRenderer : {
					type : "InputEditRenderer",
					allowPoint : true,  // 소수점( . ) 도 허용할지 여부
					onlyNumeric : true, // Input 에서 숫자만 가능케 설정
				},
				editable : true,
			},
			{
				headerText : "취득(금액)",
				dataField : "ability_amt",
				width : "100",
				style : "aui-right",
				dataType : "numeric",
				editable : false,
			},
			{
				headerText : "설명",
				dataField : "remark",
				style : "aui-left aui-editable",
				editable : true,
				editRenderer : {
					type : "InputEditRenderer",
					maxlength : 50,
				},
			},
			{
				headerText : "정렬순서",
				dataField : "sort_no",
				width : "80", 
				style : "aui-center aui-editable",
				dataType : "numeric",
				editable : true,
				editRenderer : {
					type : "InputEditRenderer",
					allowPoint : false,  // 소수점( . ) 도 허용할지 여부
					onlyNumeric : true, // Input 에서 숫자만 가능케 설정
				},
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
		];
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, []);
		
		AUIGrid.bind(auiGrid, "cellEditEnd", function (event) {
			// 배율 이벤트 바인딩
			if (event.dataField == "ability_rate") {
				// 배율 0.5 단위로 강제 지정
				var value = Math.round(event.value * 2) / 2;
				AUIGrid.updateRow(auiGrid, { "ability_rate" : value }, event.rowIndex);
				// 취득금액 자동계산
				var amt = isBlankAvgUpSalary() ? value * event.item.ability_amt : value * Number($M.getValue("avg_up_salary_amt"));
				AUIGrid.updateRow(auiGrid, { "ability_amt" : amt }, event.rowIndex);
			}
			// 구분 이벤트 바인딩
			else if (event.dataField == "hr_ability_cd") {
				if (!event.value) {
					AUIGrid.updateRow(auiGrid, { "hr_ability_cd" : "선택" }, event.rowIndex);
				}
			}
		});
	}

	// 행추가 버튼 이벤트
	function fnAdd() {
		var item = {};
		item.hr_ability_cd = "선택";
		item.ability_name = "";
		item.hr_code_ability_seq = 0; // sequence
		item.ability_rate = 0;
		item.ability_amt = 0;
		item.remark = "";
		item.sort_no = 0;
		item.use_yn = "Y";
		AUIGrid.addRow(auiGrid, item, 'last');
	}
	
	// 그리드 필수항목 체크
	function fnCheckGridEmpty() {
		// 필수값
		var requiredValue = [
			"ability_name", // 수당명
			"ability_rate", "sort_no" // 배율, 정렬순서
		];
		return AUIGrid.validateGridData(auiGrid, requiredValue, "필수 항목은 반드시 값을 입력해야합니다.");
	}

	// 저장
	function goSave() {
		if (!fnCheckGridEmpty(auiGrid)) {
			return;
		}

		var validCode = AUIGrid.getGridData(auiGrid).some(data => data.hr_ability_cd === "선택");
		if (validCode) {
			alert("구분 항목은 반드시 값을 입력해야합니다.");
			return;
		}
		
		var addGridData = AUIGrid.getAddedRowItems(auiGrid);  // 추가내역
		var changeGridData = AUIGrid.getEditedRowItems(auiGrid); // 변경내역
		
		if (changeGridData.length == 0 && addGridData.length == 0) {
			alert("변경내역이 없습니다.");
			return;
		}
		
		var hrAbilityCdArr = [];
		var abilityNameArr = [];
		var hrCodeAbilitySeqArr = [];
		var abilityRateArr = [];
		var abilityAmtArr = [];
		var remarkArr = [];
		var sortNoArr = [];
		var useYnArr = [];
		var cmdArr = [];
		var orgCodeStrArr = [];

		addGridData.forEach(data => {
			hrAbilityCdArr.push(data.hr_ability_cd);
			abilityNameArr.push(data.ability_name);
			hrCodeAbilitySeqArr.push(data.hr_code_ability_seq);
			abilityRateArr.push(data.ability_rate);
			abilityAmtArr.push(data.ability_amt);
			remarkArr.push(data.remark);
			sortNoArr.push(data.sort_no);
			useYnArr.push(data.use_yn);
			orgCodeStrArr.push(data.org_code_str);
			cmdArr.push("C");
		});
		
		changeGridData.forEach(data => {
			hrAbilityCdArr.push(data.hr_ability_cd);
			abilityNameArr.push(data.ability_name);
			hrCodeAbilitySeqArr.push(data.hr_code_ability_seq);
			abilityRateArr.push(data.ability_rate);
			abilityAmtArr.push(data.ability_amt);
			remarkArr.push(data.remark);
			sortNoArr.push(data.sort_no);
			useYnArr.push(data.use_yn);
			orgCodeStrArr.push(data.org_code_str);
			cmdArr.push("U");
		})

		var option = {
			isEmpty : true // 빈칸 허용 여부
		};
		
		var param = {
			hr_ability_cd_str : $M.getArrStr(hrAbilityCdArr, option),
			ability_name_str : $M.getArrStr(abilityNameArr, option),
			hr_code_ability_seq_str : $M.getArrStr(hrCodeAbilitySeqArr, option),
			ability_rate_str : $M.getArrStr(abilityRateArr, option),
			ability_amt_str : $M.getArrStr(abilityAmtArr, option),
			remark_str : $M.getArrStr(remarkArr, option),
			sort_no_str : $M.getArrStr(sortNoArr, option),
			use_yn_str : $M.getArrStr(useYnArr, option),
			cmd_str : $M.getArrStr(cmdArr, option),
			org_code_str_str : $M.getArrStr(orgCodeStrArr, option),
			avg_up_salary_amt : $M.getValue("avg_up_salary_amt"),
		}
		
		$M.goNextPageAjaxSave("/comm/comm012006/save", $M.toGetParam(param) , {method : 'POST'},
			function(result) {
	    		if (result.success) {
	    			alert("저장이 완료되었습니다.");
	    			goSearch();
				}
			}
		);
	}

	// 적용
	function goApply() {
		var avgUpSalary = $M.getValue("avg_up_salary_amt"); // 평균 상승 연봉

		if (isBlankAvgUpSalary()) {
			alert("평균 상승 연봉을 입력해주세요.");
			return;
		}

		var gridData = AUIGrid.getGridData(auiGrid);
		for (var i = 0; i < gridData.length; i++) {
			var data = AUIGrid.getGridData(auiGrid);
			AUIGrid.updateRow(auiGrid, { "ability_amt" : Number(avgUpSalary) * Number(data[i].ability_rate)}, i);
		}
	}

	function isBlankAvgUpSalary() {
		var avgUpSalary = $M.getValue("avg_up_salary_amt"); // 평균 상승 연봉
		return avgUpSalary == "0" || avgUpSalary == "";

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
							<th>수당명</th>
							<td>
								<input type="text" class="form-control" id="s_ability_name" name="s_ability_name">
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
						<span>평균 상승 연봉</span>
						<input type="text" style="width: 120px; text-align: right;" id="avg_up_salary_amt" name="avg_up_salary_amt" format="num">
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