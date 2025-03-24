<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 서비스비용설정 > null > 서비스비용 산출현황
-- 작성자 : 임예린
-- 최초 작성일 : 2021-08-10 13:42:37
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
	var auiGrid;
	var machineGroupByMaker = ${machineGroupByMaker}
	
	$(document).ready(function() {
		// AUIGrid 생성
		createAUIGrid();
		goSearch();
	});

	// 조회
	function goSearch() {
		if($M.getValue("s_start_dt")=="" || $M.getValue("s_end_dt")=="") {
			alert("날짜를 입력해 주세요.");
			return;
		}
		
		var params = {
			"s_maker_cd" : $M.getValue("s_maker_cd"),
			"s_machine_plant_seq" : $M.getValue("s_machine_plant_seq"),
			"s_start_dt" : $M.getValue("s_start_dt"),
			"s_end_dt" : $M.getValue("s_end_dt")
		};
		_fnAddSearchDt(params, 's_start_dt', 's_end_dt');
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method: 'GET'},
				function (result) {
					if (result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					}
				}
		);
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
				width : "100",
				minWidth : "100",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "모델", 
				dataField : "machine_name",
				width : "150",
				minWidth : "150",
				style : "aui-center",
				editable : false,
			},
			{ 
				headerText : "판매대수",  
				dataField : "saled_num",
				width : "120",
				minWidth : "120",
				style : "aui-right",
				dataType : "numeric",
				editable : false,
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
				headerText : "서비스비용", 
				dataField : "ba_svc_amt",
				width : "120",
				minWidth : "120",
				style : "aui-right",
				dataType : "numeric",
				editable : false,
			},
			{ 
				headerText : "무상정비건수", 
				dataField : "free_mch_num",
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
				headerText : "변경이력",
				dataField : "svc_dt",
				width : "120",
				minWidth : "120",
				style : "aui-center aui-popup",
				dataType : "date",   
				formatString : "yy-mm-dd",
				editable : false,
			},
			{
				dataField : "machine_plant_seq",
				visible : false
			}
		];

		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, []);
		
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
	
	function fnChangeMakerCd() {
		$('#s_machine_plant_seq').combogrid("reset");
		var makerCd = $M.getValue("s_maker_cd");
		var list = [];
		if (makerCd != "") {
			list = machineGroupByMaker[makerCd];
		} else {
			list = machineList;
		}
		$M.reloadComboData("s_machine_plant_seq", list);
	}
	
	// 팝업 닫기
	function fnClose() {
		window.close();
	}
	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
		<div class="content-wrap">
<!-- 검색영역 -->
			<div class="search-wrap">
				<table class="table">
					<colgroup>
						<col width="50px">
						<col width="100px">
						<col width="40px">
						<col width="100px">
						<col width="40px">
						<col width="100px">
						<col width="40px">
						<col width="140px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th>조회일자</th>
						<td colspan="3" style="min-width: 260px">
							<div class="form-row inline-pd">
								<div class="col-5">
									<div class="input-group">
										<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" alt="시작일자" value="${searchDtMap.s_start_dt }">
									</div>
								</div>
								<div class="col-auto">~</div>
								<div class="col-5">
									<div class="input-group">
										<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd" alt="종료일자" value="${searchDtMap.s_end_dt }">
									</div>
								</div>
								<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
		                     		<jsp:param name="st_field_name" value="s_start_dt"/>
		                     		<jsp:param name="ed_field_name" value="s_end_dt"/>
		                     		<jsp:param name="click_exec_yn" value="Y"/>
		                     		<jsp:param name="exec_func_name" value="goSearch();"/>
		                     	</jsp:include>
							</div>
						</td>
						<th>메이커</th>
						<td>
							<select id="s_maker_cd" name="s_maker_cd" class="form-control" onchange="fnChangeMakerCd()">
								<option value="">- 전체 -</option>
								<c:forEach items="${codeMap['MAKER']}" var="item">
									<c:if test="${item.code_v1 eq 'Y' && item.code_v2 eq 'Y'}">
										<option value="${item.code_value}" <c:if test="${result.maker_cd == item.code_value}">selected</c:if>>${item.code_name}</option>
									</c:if>
								</c:forEach>
							</select>
						</td>
						<th>모델</th>
						<td>
							<input type="text" style="width : 140px";
								id="s_machine_plant_seq" 
								name="s_machine_plant_seq" 
								easyui="combogrid"
								header="N"
								easyuiname="machineName" 
								panelwidth="140"
								maxheight="300"
								textfield="machine_name"
								multi="N"
								enter="goSearch()"
								idfield="machine_plant_seq" />
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
			</div>
			<div id="auiGrid" style="margin-top: 5px; height: 350px;"></div>
<!-- /조회결과 -->
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">	
				<div class="left">
					총 <strong id="total_cnt" class="text-primary">0</strong>건
				</div>						
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