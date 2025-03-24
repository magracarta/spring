<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 서비스업무평가-개인 > null > 서비스 비용 이관
-- 작성자 : 정윤수
-- 최초 작성일 : 2023-12-06 17:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	var auiGrid;
	$(document).ready(function() {
		createAUIGrid();
		fnInit();
	});

	function fnInit() {
		<%--var cowokerList = [];--%>
		<%--<c:if test ="${not empty list}">--%>
		<%-- cowokerList = ${list}--%>
		<%--</c:if>--%>
		
		
		<%--if('${inputParam.s_type}' != 'D' && cowokerList.length < 1) {--%>
		<%--	var item = new Object;--%>
		<%--	item.svc_mem_no = '${SecureUser.svc_mem_no}';--%>
		<%--	item.svc_mem_name = '${SecureUser.user_name}';--%>
		<%--	item.free_cost_rate = "";--%>
		<%--	item.free_cost_amt = "";--%>
		
		<%--	AUIGrid.addRow(auiGrid, item, 'last');--%>
		<%--}--%>
		
		// 수정가능여부가 Y가 아니면 수정불가
		if("${inputParam.modify_yn}" != 'Y'){
			$("#_goSave").addClass("dpn");
			$("#_fnAdd").addClass("dpn");
			AUIGrid.hideColumnByDataField(auiGrid, ["remark"]); // 숨길대상
			AUIGrid.setColumnProp(auiGrid, 4, {editable: false, style : "aui-center"}); // 비율컬럼 속성 수정
		}
	}
	
	// 직원추가
	function fnAdd() {
		openMemberOrgPanel('setMemberOrgMapPanel', 'Y', "agency_yn=N");
	}
	
	function setMemberOrgMapPanel(data) {
		// 조회된게 기존 그리드에 있으면 추가안함(사용여부 상관 없음)
		for(var i in data) {
			if (!isGridData(auiGrid, "svc_mem_no", data[i].mem_no) && data[i].mem_no != "") {
				var item = new Object();
				item.machine_doc_no = '${inputParam.machine_doc_no}';
				item.svc_mem_name = data[i].mem_name;
				item.svc_mem_no = data[i].mem_no;
				item.svc_org_code = data[i].org_code;
				item.free_cost_rate = "";
				item.free_cost_amt = "";
				item.use_yn = "Y";
	
				AUIGrid.addRow(auiGrid, item, 'last');
			}
		}
	}
	
	// 그리드에 포함된 값인지
	function isGridData(auiGrid, column, value) {
		var uniqueValues = AUIGrid.getColumnDistinctValues(auiGrid, column);
		for (var i in uniqueValues) {
			if (value == uniqueValues[i]) {
				return true;
			}
		}
		return false;
	}

	// 저장
	function goSave() {
		var allData = AUIGrid.getGridData(auiGrid);
		var data = [];
		for(var i=0; i<allData.length;i++){
			if(allData[i].use_yn != 'N'){
				data.push(allData[i]);
			}
		}
		var workRate = 0;
		var workAmt = 0;
		for(var i=0; i<data.length; i++) {
			workRate += $M.toNum(data[i].free_cost_rate);
			workAmt += $M.toNum(data[i].free_cost_amt);
		}

		if(data.length > 0 && workRate != 100) {
			alert("비율의 총 합을 100%로 만들어 주세요.");
			return;
		}
		if (fnChangeGridDataCnt(auiGrid) == 0) {
			alert("변경된 데이터가 없습니다.");
			return false;
		};

		var frm = fnChangeGridDataToForm(auiGrid);
		$M.goNextPageAjaxSave(this_page + "/save", frm, {method : "POST"},
				function(result) {
					if(result.success) {
						location.reload();
						window.opener.location.reload();
					};
				}
		);
	}

	// 닫기
	function fnClose() {
		window.close();
	}

	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn: false,
			// 체크박스 출력 여부
			showRowCheckColumn : false,
			// 전체선택 체크박스 표시 여부
			showRowAllCheckBox : false,
			showStateColumn : true,
			editable : true,
			showFooter : true,
			footerPosition : "top",
		};
		var columnLayout = [
			{
				dataField : "machine_doc_no",
				visible : false
			},
			{
				headerText : "서비스정산코드",
				dataField : "svc_org_code",
				visible : false
			},
			{
				headerText : "직원명",
				dataField : "svc_mem_name",
				style : "aui-center",
				editable: false,
				width : "20%"
			},
			{
				headerText : "직원코드",
				dataField : "svc_mem_no",
				visible : false
			},
			{
				headerText : "비율(%)",
				dataField : "free_cost_rate",
				style : "aui-center aui-editable",
				width : "20%",
				dataType : "numeric",
				formatString : "##0",
				postfix : " %", // 접미사
				editRenderer : {
					type : "InputEditRenderer",
					onlyNumeric : true,
					allowPoint : false,  // 소수점( . ) 도 허용할지 여부
					maxlength : 3, // 최대길이
					max : 100, // 최대값
					min : 0, // 최소값
					// 에디팅 유효성 검사
					validator : AUIGrid.commonValidator
				},
			},
			{
				headerText : "서비스비용(원)",
				dataField : "free_cost_amt",
				style : "aui-right",
				width : "40%",
				editable: false,
				dataType : "numeric",
				formatString : "#,##0",
				postfix : " 원" // 접미사
			},
			{
				headerText : "삭제",
				dataField : "remark",
				style : "aui-left",
				width : "20%",
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
						if (isRemoved == false) {
							AUIGrid.updateRow(auiGrid, {use_yn : "N"}, event.rowIndex);
							AUIGrid.removeRow(event.pid, event.rowIndex);
						} else {
							AUIGrid.restoreSoftRows(auiGrid, "selectedIndex");
							AUIGrid.updateRow(auiGrid, {use_yn : "Y"}, event.rowIndex);
						}
					}
				},
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					return '삭제'
				},
			},
			{
				dataField : "use_yn",
				visible : false
			},
		];

		// 푸터레이아웃
		var footerColumnLayout = [
			{
				labelText : "합계",
				positionField : "svc_mem_name",
				style : "aui-center aui-footer",
			},
			{
				dataField : "free_cost_rate",
				positionField : "free_cost_rate",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-center aui-footer",
				postfix : " %", // 접미사
			},
			{
				dataField : "free_cost_amt",
				positionField : "free_cost_amt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer",
				postfix : " 원", // 접미사
			}
		];

		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, ${list});

		AUIGrid.setFooter(auiGrid, footerColumnLayout);
		$("#auiGrid").resize();

		// 공임비율 입력 시 공임액 계산
		AUIGrid.bind(auiGrid, "cellEditEnd", auiCellEditHandler);
	}

	// 공임비율 입력 시 공임액 계산
	function auiCellEditHandler(event) {
		switch (event.type) {
			case "cellEditEnd" :
				if(event.dataField == "free_cost_rate") {
					var workTotalAmt = '${inputParam.free_cost_amt}';
					workTotalAmt = $M.toNum(workTotalAmt);
					var workRate = $M.toNum(event.item.free_cost_rate);
					var result = workTotalAmt * workRate / 100;

					AUIGrid.updateRow(auiGrid, {"free_cost_amt" : result}, event.rowIndex);
				}
				break;
		}
	}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<!-- 의견추가내역 -->
			<div class="title-wrap mt5">
				<h4>서비스 비용 이관</h4>
				<div class="right half-print">
					<span class="condition-item mr5">서비스비용 : ${inputParam.free_cost_amt} 원</span>
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
				</div>
			</div>
			<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
			<!-- /의견추가내역 -->
			<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
			<!-- /그리드 서머리, 컨트롤 영역 -->
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>