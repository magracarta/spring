<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 서비스비용설정 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-08-10 13:42:37
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
	var auiGrid;
	
	$(document).ready(function() {
		// AUIGrid 생성
		createAUIGrid();
		goSearch();
	});

	// 조회
	function goSearch() {
		var params = {
			"s_maker_cd" : $M.getValue("s_maker_cd"),
		};
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method: 'GET'},
				function (result) {
					if (result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					}
				}
		);
	}
	
	function goSave() {
		
		if (fnChangeGridDataCnt(auiGrid) == 0) {
			alert("변경된 데이터가 없습니다.");
			return false;
		}
		
		var frm = fnChangeGridDataToForm(auiGrid);
		
		$M.goNextPageAjaxSave(this_page+"/save", frm, {method : 'POST'},
				function(result) {
			    	if(result.success) {
			    		goSearch();
					}
				}
			);
	}

	// 엑셀다운로드
	function fnDownloadExcel() {
		fnExportExcel(auiGrid, "서비스비용설정");
	}	

	//그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn: true,
			editable : true,
			// fixedColumnCount : 7,
		};
		var columnLayout = [
			{ 
				headerText : "메이커", 
				dataField : "maker_name",
				width : "80",
				minWidth : "80",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "모델", 
				dataField : "machine_name",
				width : "120",
				minWidth : "120",
				style : "aui-center",
				editable : false,
			},
			{ 
				headerText : "설정일", // 원가적용시작일이라고 하기로함!  
				dataField : "price_apply_st_dt",
				width : "90",
				minWidth : "90",
				style : "aui-center",
				dataType : "date",   
				formatString : "yy-mm-dd",
				editable : false,
			},
			{ 
				headerText : "최저판매가", 
				dataField : "min_sale_price",
				width : "100",
				minWidth : "100",
				style : "aui-right",
				dataType : "numeric",
				editable : false,
			},
			{ 
				headerText : "서비스비용", 
				dataField : "ba_svc_amt",
				width : "100",
				minWidth : "100",
				style : "aui-right",
				dataType : "numeric",
				editable : false,
			},
			{ 
				headerText : "출하비용설정(%)", 
				dataField : "out_cost_rate",
				width : "120",
				minWidth : "120",
				style : "aui-right aui-editable",
				dataType : "numeric",
				editable : true,
				editRenderer: {
                    type: "InputEditRenderer",
                    onlyNumeric: true
                },
			},
			{ 
				headerText : "출하비용", 
				dataField : "out_cost_amt",
				width : "120",
				minWidth : "120",
				style : "aui-right",
				dataType : "numeric",
				editable : false,
			},
			{ 
				headerText : "무상비용설정(%)", 
				dataField : "free_cost_rate",
				width : "120",
				minWidth : "120",
				style : "aui-right",
				dataType : "numeric",
				editable : false,
			},
			{ 
				headerText : "무상비용", 
				dataField : "free_cost_amt",
				width : "120",
				minWidth : "120",
				style : "aui-right",
				dataType : "numeric",
				editable : false,
			},
			{
				headerText : "비고",
				dataField : "remark",
				width : "230",
				minWidth : "230",
				style : "aui-left aui-editable",
				editable : true,
			},
			{
				headerText : "변경이력",
				dataField : "svc_dt",
				width : "90",
				minWidth : "90",
				style : "aui-center aui-popup",
				dataType : "date",   
				formatString : "yy-mm-dd",
				editable : false,
			},
			{
				dataField : "machine_plant_seq",
				visible : false
			},
			{
				dataField : "machine_cost_price_seq",
				visible : false
			},
			{
				dataField : "ba_svc_rate",
				visible : false
			}
		];

		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, []);
		
		AUIGrid.bind(auiGrid, "cellEditEnd", function(event) {
			// out_cost_rate
			if(event.dataField == "out_cost_rate" ) {
				var value = event.value; 
				if (event.value > 100) {
					value = 100;
					alert("최대 100입니다.");
				}
				
				var svcAmt = event.item.ba_svc_amt;
				var outCostRate = value;
				var outCostAmt = Math.ceil(svcAmt * outCostRate/100);
				var freeCostRate = 100 - outCostRate;
				var freeCostAmt = svcAmt - outCostAmt;
				
				AUIGrid.updateRow(auiGrid, { 
						  "out_cost_rate" : value,
						  "out_cost_amt" : outCostAmt,
						  "free_cost_rate" : freeCostRate,
						  "free_cost_amt" : freeCostAmt}, event.rowIndex);
			}
		});
		
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			if(event.dataField == "svc_dt" ) {
 				var params = {
 					"machine_plant_seq" : event.item.machine_plant_seq
				};
 				var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=800, left=0, top=0";
 				$M.goNextPage('/serv/serv0512p01', $M.toGetParam(params), {popupStatus : popupOption});
			}
		});	
		
		$("#auiGrid").resize();
	}
	
	function goServCostInfo() {
		var params = { };
		var popupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=531, left=0, top=0";
		$M.goNextPage('/serv/serv0512p03', $M.toGetParam(params), {popupStatus : popupOption});
	}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
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
					<!-- 검색영역 -->
					<div class="search-wrap">
						<table class="table">
							<colgroup>
								<col width="40px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th>메이커</th>
								<td>
									<select class="form-control" id="s_maker_cd" name="s_maker_cd" onchange="javascript:goSearch();">
										<option value="">- 전체 -</option>
										<c:forEach items="${makers}" var="item">
											<option value="${item.maker_cd}"
													<c:if test="${empty inputParam.s_maker_cd and '27' eq item.maker_cd}">selected</c:if>
													<c:if test="${not empty inputParam.s_maker_cd and inputParam.s_maker_cd eq item.maker_cd}">selected</c:if>
											>${item.maker_name}</option>
										</c:forEach>
									</select>
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /검색영역 -->
					<!-- 조회결과 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<span class="text-warning">※ 서비스비용은 마케팅 > 장비원가대장에 등록가능합니다. 서비스비용 0 아닌 장비만 조회합니다. 품의서 작성 당시 장비의 서비스비용으로 고정됩니다.</span>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<!-- /조회결과 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<div class="btn-group mt5">
						<div class="left">
							총 <strong id="total_cnt" class="text-primary">0</strong>건
						</div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
				</div>
			</div>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>