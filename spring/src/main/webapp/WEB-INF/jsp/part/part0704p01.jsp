<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 코드관리 > 부품판가산출지표 > null > 기준산출코드 History
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-04-22 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var auiGrid;

	$(document).ready(function() {
		createAUIGrid(); // 메인 그리드
	});
	
	// 산출구분표 그리드 생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid", 
			// rowNumber 
			showRowNumColumn: true,
			// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
			wrapSelectionMove : false,
			showStateColumn : false,
			editable : false,
		};
		var columnLayout = [
			{
				dataField : "part_price_log_seq",
				visible : false
			},
			{
				dataField : "part_price_vip_rate",
				visible : false
			},
			{ 
				headerText : "변경일시", 
				dataField : "reg_date", 
				width : "50%", 
				style : "aui-center aui-popup",
				dataType : "date",
				formatString : "yy-mm-dd HH:MM:ss",
			},
			{ 
				headerText : "등록자", 
				dataField : "reg_mem_name", 
				width : "50%", 
				style : "aui-center",
			},
		];
		
		// 실제로 #grid_wrap 에 그리드 생성
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGrid, ${list});
		$("#total_cnt").html(${total_cnt});
		
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			if(event.dataField == "reg_date") {
				param = {			
						part_price_log_seq : event.item.part_price_log_seq
				};	
			
				var poppupOption = "";
				$M.goNextPage('/part/part0704p02', $M.toGetParam(param), {popupStatus : poppupOption});
			}
		});
	}
	
	// 닫기
	function fnClose() {
		window.close();
	}
	
	// 조회
	function goSearch() {
		var param = {
				s_search_yn : "Y",
				s_start_dt : $M.getValue("s_start_dt"),
				s_end_dt : $M.getValue("s_end_dt"),
			};
			
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					$("#total_cnt").html(result.total_cnt);
					AUIGrid.setGridData(auiGrid, result.list);
				};
			}		
		);			
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
						</colgroup>
						<tbody>
							<tr>
								<th>변경일자</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" required="required" value="${inputParam.s_start_dt}">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" required="required" value="${inputParam.s_end_dt}">
											</div>
										</div>
									</div>
								</td>
								<td class=""><button type="button" class="btn btn-important" style="width: 55px;" onclick="javascript:goSearch();">조회</button></td>
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