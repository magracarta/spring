<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 고객관리 > 전화업무 통합관리 > Happy Call > 응답현황
-- 작성자 : 이강원
-- 최초 작성일 : 2023-07-03 15:00:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

	var auiGrid;
	
	$(document).ready(function() {
		// AUIGrid 생성
		createAUIGrid();
		goSearch();
	});

	function goSearch() {
		var param = {
			s_start_dt : $M.getValue("s_start_dt"),
			s_end_dt : $M.getValue("s_end_dt"),
			s_masking_yn : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
		};

		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						var list = result.list;

						AUIGrid.setGridData(auiGrid, list);
						$("#total_cnt").html(result.total_cnt);
					};
				}
		);
	}
	
	//그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "row",
			showRowNumColumn: true,
		};
		var columnLayout = [
			{ 
				headerText : "정비지시서 번호",
				dataField : "job_report_no",
				style : "aui-center",
				width : "110"
			},
			{
				headerText : "정비일자",
				dataField : "work_dt",
				style : "aui-center",
				dataType : "date",
				formatString : "yyyy-mm-dd",
				width : "80"
			},
			{
				headerText : "회신일자",
				dataField : "ans_dt",
				style : "aui-center",
				dataType : "date",
				formatString : "yyyy-mm-dd",
				width : "80"
			},
			{
				headerText : "고객명",
				dataField : "cust_name",
				style : "aui-left",
				width : "100"
			},
			{ 
				headerText : "연락처",
				dataField : "hp_no",
				style : "aui-center",
				width : "120"
			},
			{ 
				headerText : "주소",
				dataField : "addr",
				style : "aui-center",
				width : "200"
			},
			{
				headerText : "모델명",
				dataField : "machine_name",
				style : "aui-center",
				width : "120"
			},
			{ 
				headerText : "차대번호",
				dataField : "body_no",
				style : "aui-center",
				width : "150"
			},
			{
				headerText : "담당센터",
				dataField : "org_name",
				style : "aui-center",
				width : "80"
			},
			{
				headerText : "정비기사",
				dataField : "eng_mem_name",
				style : "aui-center",
				width : "80"
			},
			{ 
				headerText : "회신내용",
				dataField : "ans_text",
				style : "aui-center",
				width : "500"
			}
		];
		
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, []);
		
		$("#auiGrid").resize();

		// 만약 칼럼 사이즈들의 총합이 그리드 크기보다 작다면, 나머지 값들을 나눠 가져 그리드 크기에 맞추기
		// var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);

		// 구해진 칼럼 사이즈를 적용 시킴.
		// AUIGrid.setColumnSizeList(auiGrid, colSizeList);
	}

	// 엑셀다운로드
	function fnDownloadExcel() {
		fnExportExcel(auiGrid, '해피콜 응답현황');
	}
	
	// 닫기
    function fnClose() {
    	window.close();
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
			<div class="search-wrap mt5">
				<table class="table table-fixed">
					<colgroup>
						<col width="65px">
						<col width="250px">
						<col width="90px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th>응답일자</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width120px">
									<div class="input-group">
										<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" value="${inputParam.s_start_dt}" dateFormat="yyyy-MM-dd" alt="조회 시작일">
									</div>
								</div>
								<div class="col width16px text-center">~</div>
								<div class="col width120px">
									<div class="input-group">
										<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd"  value="${inputParam.s_end_dt}" alt="조회 완료일">
									</div>
								</div>
							</div>
						</td>
						<td>
							<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
						</td>
						<td>
							<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
								<div class="form-check form-check-inline">
									<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
									<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
								</div>
							</c:if>
						</td>
					</tr>
					</tbody>
				</table>
			</div>
<!-- 폼테이블 -->					
			<div>
				<div class="title-wrap mt5">
					<h4>응답목록</h4>
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 650px;"></div>
			</div>
<!-- /폼테이블-->					
			<div class="btn-group mt10">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
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