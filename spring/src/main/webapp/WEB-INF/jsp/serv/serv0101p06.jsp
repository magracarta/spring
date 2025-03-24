<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비지시서 > null > 리콜처리확인
-- 작성자 : 성현우
-- 최초 작성일 : 2020-07-02 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	var auiGrid;
	$(document).ready(function() {
		fnDateInit();
		createAUIGrid();

		goSearch();
	});

	function fnDateInit() {
		var now = "${inputParam.s_current_dt}";
		$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1));
	}

	function goSearch() {
		$M.setValue("__s_machine_seq", ${inputParam.__s_machine_seq});

		var frm = document.main_form;
		//validationcheck
		if($M.validation(frm,
				{field:["s_start_dt", "s_end_dt"]}) == false) {
			return;
		};

		var params = {
			"__s_machine_seq" : $M.getValue("__s_machine_seq"),
			"s_start_dt" : $M.getValue("s_start_dt"),
			"s_end_dt" : $M.getValue("s_end_dt"),
			"s_complete_yn" : $M.getValue("s_complete_yn")
		};

		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method : 'GET'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
		);
	}

	//엑셀다운로드
	function fnDownloadExcel() {
		fnExportExcel(auiGrid, "리콜처리확인");
	}

	// 닫기
	function fnClose() {
		window.close();
	}

	//그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn: true,
		};
		var columnLayout = [
			{ 
				headerText : "등록일자", 
				dataField : "reg_date",
				width : "10%",
				style : "aui-center aui-popup",
				dataType : "date",  
				formatString : "yyyy-mm-dd"
			},
			{
				headerText : "리콜명", 
				dataField : "campaign_name",
				width : "10%",
				style : "aui-center"
			},
			{ 
				headerText : "시작일자", 
				dataField : "campaign_st_dt",
				width : "10%",
				style : "aui-center",
				dataType : "date",  
				formatString : "yyyy-mm-dd"
			},
			{ 
				headerText : "종료일자", 
				dataField : "campaign_ed_dt",
				width : "10%",
				style : "aui-center",
				dataType : "date",  
				formatString : "yyyy-mm-dd"
			},
			{ 
				headerText : "리콜내용", 
				dataField : "content",
				width : "25%",
				style : "aui-left"
			},
			{ 
				headerText : "처리일자", 
				dataField : "proc_date",
				width : "10%",
				style : "aui-center",
				dataType : "date",  
				formatString : "yyyy-mm-dd"
			},
			{ 
				headerText : "처리사항",
				width : "25%",
				dataField : "proc_text",
				style : "aui-left"
			},
			{
				headerText : "캠페인번호",
				dataField : "campaign_seq",
				visible : false
			},
			{
				headerText : "장비대장번호",
				dataField : "machine_seq",
				visible : false
			}
		];

		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, []);
		
		$("#auiGrid").resize();

		AUIGrid.bind(auiGrid, "cellClick", function (event) {
			if (event.dataField == "reg_date") {
				var params = {
					"campaign_seq": event.item.campaign_seq,
					"machine_seq" : event.item.machine_seq
				};
				var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=300, height=200, left=0, top=0";
				$M.goNextPage('/serv/serv0101p12', $M.toGetParam(params), {popupStatus: popupOption});
			}
		});
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
							<col width="65px">
							<col width="270px">
							<col width="50px">
							<col width="100px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th>등록일자</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="시작일자">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="종료일자" value="${inputParam.s_current_dt}">
											</div>
										</div>
									</div>
								</td>
								<th>자료구분</th>
								<td>
									<select id="s_complete_yn" name="s_complete_yn" class="form-control">
										<option value="" >- 전체 -</option>
										<option value="N" >기간 내</option>
										<option value="Y" >기간 외</option>
									</select>
								</td>
								<td class=""><button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button></td>
							</tr>
						</tbody>
					</table>
				</div>
<!-- /검색영역 -->
<!-- 조회결과 -->
				<div class="title-wrap mt10">
					<h4>조회결과</h4>
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
<!-- /조회결과 -->
			</div>		
<!-- /폼테이블 -->
			<div class="btn-group mt10">
				<div class="left">
					총 <strong id="total_cnt" class="text-primary">0</strong>건
				</div>	
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>