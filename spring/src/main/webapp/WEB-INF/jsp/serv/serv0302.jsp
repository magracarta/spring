<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 쿠폰관리 > 프로모션관리 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-04-07 19:54:29
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
	});
	
	//그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "row",
			showRowNumColumn: true,
		};
		var columnLayout = [
			{ 
				headerText : "시행부서", 
				dataField : "org_name", 
				style : "aui-center",
			},
			{
				headerText : "제목", 
				dataField : "title", 
				width : "20%",
				style : "aui-left aui-popup",
			},
			{ 
				headerText : "내용", 
				dataField : "content", 
				width : "20%",
				style : "aui-left",
			},
			{ 
				headerText : "시작일자", 
				dataField : "start_dt", 
				style : "aui-center",
				dataType : "date",  
				formatString : "yyyy-mm-dd",
			},
			{ 
				headerText : "종료일자", 
				dataField : "end_dt", 
				style : "aui-center",
				dataType : "date",  
				formatString : "yyyy-mm-dd",
			},
			{ 
				headerText : "등록일자", 
				dataField : "reg_date", 
				style : "aui-center",
				dataType : "date",  
				formatString : "yyyy-mm-dd",
			},
			{ 
				headerText : "등록자", 
				dataField : "reg_mem_name", 
				style : "aui-center",
			},
			{ 
				headerText : "상태", 
				dataField : "status_name", 
				style : "aui-center",
			},
			{
				dataField : "pro_seq",
				visible : false
			}
		];
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, []);
		
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			if(event.dataField == "title" ) {
				var params = {
					pro_seq : event.item.pro_seq
				};
				var popupOption = "scrollbars=yes, resizable=yes, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1400, height=950, left=0, top=0";
				$M.goNextPage('/serv/serv0302p01', $M.toGetParam(params), {popupStatus : popupOption});
			}
		});	
		$("#auiGrid").resize();
	}
	
	// 조회
	function goSearch() {
		var param = {
			s_org_code : $M.getValue("s_org_code"),
			s_status_cd : $M.getValue("s_status_cd"),
			s_sort_key : "reg_date",
			s_sort_method : "desc"
		};
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					console.log(result.list);
					$("#total_cnt").html(result.total_cnt);
					AUIGrid.setGridData(auiGrid, result.list);
				};
			}
		);
	}
	
	function fnDownloadExcel() {
    	fnExportExcel("프로모션 목록", {});
    }
	
	// 신규등록
	function goNew() {
		$M.goNextPage("/serv/serv030201");
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
						<table class="table table-fixed">
							<colgroup>
								<col width="60px">
								<col width="120px">				
								<col width="50px">
								<col width="100px">	
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>시행부서</th>
									<td>
										<select class="form-control" name="s_org_code">
											<option value="">- 전체 -</option>
											<option value="4000">마케팅</option>
											<option value="5000">서비스</option>
											<option value="6000">부품영업부</option>
										</select>
									</td>
									<th>상태</th>
									<td>
										<select class="form-control" name="s_status_cd">
											<option value="">- 전체 -</option>
											<option value="ongoing">진행중</option>
											<option value="pending">예정</option>
											<option value="expiration">종료</option>
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
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->	
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<div class="btn-group mt5">	
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>
						<div class="right">
							<button type="button" class="btn btn-info" onclick="javascript:goNew();">신규등록</button>
						</div>
					</div>
				</div>						
			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>		
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>