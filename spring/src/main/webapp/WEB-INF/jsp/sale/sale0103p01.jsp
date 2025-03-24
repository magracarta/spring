<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 계약출하순번관리 > null > 계약수량관리
-- 작성자 : 황빛찬
-- 최초 작성일 : 2022-12-21 10:03:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<style type="text/css">

		/* 커스텀 행 스타일 ( 세로선 ) */
		.my-column-style {
			border-right: 1px solid #000000 !important;
		}

		.my-column-style-red {
			color:red;
			font-weight:bold;
		}

		.my-column-style-green {
			color:green;
			font-weight:bold;
		}

		.my-column-style-black {
			color:black;
			font-weight:bold;
		}

	</style>
	<script type="text/javascript">

		var auiGrid;
		var array = [];
		var yearMonList = [];
		var dataFieldName = [];
		var fieldStatusName = [];

		var machinePlantSeqArr = [];

		$(document).ready(function() {
			fnInit();
			createAUIGrid();
			goSearch();
		});

		function fnInit() {
			yearMonList = ${yearMonList};

			for(var i = 1; i <= yearMonList.length; ++i) {
				dataFieldName.push("a_month" + [i] + "_appr_qty");
			}
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showStateColumn : false,
				useGroupingPanel : false,
				showRowNumColumn: false,
				displayTreeOpen : true,
				enableCellMerge : true,
				showBranchOnGrouping : false,
				summaryMergePolicy : "all",
				//푸터 상단 고정
				footerPosition : "top",
				showFooter : false,
				editable : false,
				enableFilter :true,
				headerHeights : [25, 45],
				// [15324] 틀 고정
				fixedColumnCount : 2,

				rowStyleFunction : function(rowIndex, item) {
					if(item.maker_name.indexOf("합계") != -1 ||
							item.maker_name.indexOf("총계") != -1 ||
							item.machine_name.indexOf("합계") != -1) {
						return "aui-grid-row-depth3-style";
					}
					return null;
				}
			};

			var columnLayout = [];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);

		}
		
		// 닫기
		function fnClose() {
			window.close(); 
		}
		
		function goSearch() {
			var sFromYear = $M.getValue("s_from_year");
			var sFromMon = $M.getValue("s_from_mon");
			var sToYear = $M.getValue("s_to_year");
			var sToMon = $M.getValue("s_to_mon");

			if (sFromMon.length == 1) {
				sFromMon = "0" + sFromMon;
			}

			if (sToMon.length == 1) {
				sToMon = "0" + sToMon;
			}

			var sFromYearMon = sFromYear + sFromMon;
			var sToYearMon = sToYear + sToMon;

			if ($M.toNum(sFromYearMon) > $M.toNum(sToYearMon)) {
				alert("시작일자가 종료일자보다 클 수 없습니다.");
				return false;
			}

			var param = {
				s_from_year : $M.getValue("s_from_year"),
				s_from_mon : $M.getValue("s_from_mon"),
				s_to_year : $M.getValue("s_to_year"),
				s_to_mon : $M.getValue("s_to_mon"),
				s_machine_plant_seq_str : $M.getArrStr(machinePlantSeqArr, {isEmpty : true}),
				s_maker_cd_str : $M.getValue("s_maker_cd_str")
			}

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result){
					if(result.success) {
						fnResult(result);
					}
				}
			);
		}

		// 조회 후 그리드 갱신
		function fnResult(result) {
			yearMonList = result.yearMonList;
			dataFieldName = [];

			for(var i = 1; i <= yearMonList.length; ++i) {
				dataFieldName.push("a_month" + [i] + "_appr_qty");
			}

			if (result.success) {
				var columnLayout = [
					{
						dataFiled : "machine_plant_seq",
						visible : false
					},
					{
						headerText : "메이커",
						dataField : "maker_name",
						width : "110",
						minWidth : "20",
						style : "aui-center",
						cellMerge : true, // 셀 세로 병합 실행
						filter : {
							showIcon : true
						}
					},
					{
						headerText : "모델명",
						dataField : "machine_name",
						width : "120",
						minWidth : "20",
						styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
							if(item.machine_name.indexOf("합계") != -1 ) {
								return "aui-center";
							}
							return "aui-left";
						},
						filter : {
							showIcon : true
						}
					},
				];

				var columnObjArr = []; // 생성할 컬럼 배열

				for (var i = 0; i < dataFieldName.length; ++i) {
					var dataField = dataFieldName[i];
					var columnObj = {
						headerText : yearMonList[i].substring(4,6) + "월",
						dataField : dataField,
						width : "6%",
						// headerStyle : "aui-fold",
						style : "aui-center",
						labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
							value = AUIGrid.formatNumber(value, "#,##0");
							return value == 0 ? "" : value;
						},
						styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
							if(item.machine_name.indexOf("합계") != -1 || item.maker_name.indexOf("총계")!= -1 || item.maker_name.indexOf("합계") != -1) {
								return "";
							};

							// 계약수량 색 구분
							// 생산발주 수량 = 계약수량 : 검정
							// 생산발주 수량 > 계약수량 : 초록
							// 생산발주 수량 < 계약수량 : 빨강
							if (value != "" && item.machine_name == '계약') {
								var apprQtyStyleFieldName = dataField + "_style";

								if (item[apprQtyStyleFieldName] == "R") {
									return "my-column-style-red";
								} else if (item[apprQtyStyleFieldName] == "G") {
									return "my-column-style-green";
								} else if (item[apprQtyStyleFieldName] == "B") {
									return "my-column-style-black";
								} else {
									return "";
								}
							}
						}
					}

					columnObjArr.push(columnObj);
				}

				// 컬럼 추가.
				AUIGrid.changeColumnLayout(auiGrid, columnLayout);
				AUIGrid.addColumn(auiGrid, columnObjArr, 3);
				AUIGrid.setGridData(auiGrid, result.list);
			}
		}

		// 모델 다중조회 결과
		function setModelInfo(data) {
			var machineName = data[0].machine_name;
			var machineCnt = data.length - 1;

			if (data.length > 1) {
				machineName += " 외" + machineCnt + "건";
			}

			$M.setValue("s_machine_name", machineName);

			machinePlantSeqArr = [];
			for (var i = 0; i < data.length; i++) {
				machinePlantSeqArr.push(data[i].machine_plant_seq);
			}
		}

		function fnModelClear() {
			machinePlantSeqArr = [];
			$M.clearValue({field:["s_machine_name"]});
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
<!-- 폼테이블 -->					
			<div>					
<!-- 검색영역 -->					
				<div class="search-wrap mt5">
					<table class="table">
						<colgroup>
							<col width="50px">
							<col width="280px">
							<col width="50px">
							<col width="120px">
							<col width="50px">
							<col width="150px">
						</colgroup>
						<tbody>
							<tr>
								<th>생산월</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-auto">
											<select class="form-control width120px" name="s_from_year" id="s_from_year">
												<c:forEach var="i" begin="2007" end="${inputParam.s_current_year + 5}" step="1">
													<option value="${i}" <c:if test="${i eq fn:substring(s_from_year, 0, 4)}">selected="selected"</c:if>>${i}년</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-auto">
											<select class="form-control width120px" name="s_from_mon" id="s_from_mon">
												<c:forEach var="i" begin="01" end="12" step="1">
													<option value="${i}" <c:if test="${i eq fn:substring(s_from_year, 5, 7)}">selected="selected"</c:if>>${i}월</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-auto">~</div>
										<div class="col-auto">
											<select class="form-control width120px" name="s_to_year" id="s_to_year">
												<c:forEach var="i" begin="2007" end="${inputParam.s_current_year + 5}" step="1">
													<option value="${i}" <c:if test="${i eq fn:substring(s_end_year, 0, 4)}">selected="selected"</c:if>>${i}년</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-auto">
											<select class="form-control width120px" name="s_to_mon" id="s_to_mon">
												<c:forEach var="i" begin="01" end="12" step="1">
													<option value="${i}" <c:if test="${i eq fn:substring(s_end_year, 5, 7)}">selected="selected"</c:if>>${i}월</option>
												</c:forEach>
											</select>
										</div>
									</div>
								</td>
								<th>메이커</th>
								<td>
									<input class="form-control" style="width: 99%;" type="text" id="s_maker_cd_str" name="s_maker_cd_str" easyui="combogrid"
										   easyuiname="makerList" panelwidth="300" idfield="code_value" textfield="code_name" multi="Y"/>
								</td>
								<th>모델</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-15">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 width180px" id="s_machine_name" name="s_machine_name" alt="모델명" readonly>
												<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchModelPanel('setModelInfo', 'Y');"><i class="material-iconssearch"></i></button>
											</div>
										</div>
									</div>
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()">조회</button>
									<button type="button" class="btn btn-important" style="width: 70px;" onclick="javascript:fnModelClear()">모델초기화</button>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
<!-- /검색영역 -->			
<!-- 조회결과 -->
			<div class="title-wrap mt10">
				<h4>조회결과</h4>
			</div>
			<div id="auiGrid" style="margin-top: 10px; height: 400px;"></div>
<!-- /조회결과 -->
			</div>		
<!-- /폼테이블 -->
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">	
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