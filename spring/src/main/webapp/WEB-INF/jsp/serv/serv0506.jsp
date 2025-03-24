<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 서비스캠페인 > null > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-04-08 13:24:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>

	
	<script type="text/javascript">
		var auiGrid;
		$(document).ready(function () {
			createAUIGrid();
// 			fnInitDate();
		});
		
		function goSearch() {
	
			if($M.checkRangeByFieldName("s_campaign_st_dt", "s_campaign_end_dt", true) == false) {				
				return;
			};
			
			var param = {
				"s_start_dt" 	: $M.getValue("s_start_dt"),
				"s_end_dt" 		: $M.getValue("s_end_dt"),
				"s_kor_name" 	: $M.getValue("s_kor_name"),
				"s_status_cd" 	: $M.getValue("s_status_cd"),
				"s_center_org_code" : $M.getValue("s_center_org_code"),
				"s_sort_key" 		: "cp.reg_date",
				"s_sort_method" 	: "desc"
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
						$("#total_cnt").html(result.total_cnt);
					}
				}
			);
		};
	
		function goNew() {
			$M.goNextPage('/serv/serv050601');
		};
	
		// 엑셀다운로드
		function fnDownloadExcel() {
			  // 엑셀 내보내기 속성
			  var exportProps = {};
			  fnExportExcel(auiGrid, "서비스캠페인", exportProps);
		}
		
// 		// 시작일자 세팅 현재날짜의 1달 전
// 		function fnInitDate() {
// 			var now = "${inputParam.s_current_dt}";
// 			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -12));
// 		}
	
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "campaign_seq",
				// Row번호 표시 여부
				showRowNumColum : true,
			};
	
			var columnLayout = [
				{
					dataField : "campaign_seq",
					visible : false
				},
				{
					headerText : "등록일",
					dataField : "reg_date",
					dataType : "date",
					width : "65",
					minWidth : "65",
					formatString : "yy-mm-dd"
				},
				{
					headerText : "캠페인명",
					dataField : "campaign_name",
					width : "300",
					minWidth : "300",
					style : "aui-left aui-popup"
				},
				{
					headerText : "시작일자",
					dataField : "campaign_st_dt",
					dataType : "date",
					width : "65",
					minWidth : "65",
					formatString : "yy-mm-dd"
				},
				{
					headerText : "종료일자",
					dataField : "campaign_ed_dt",
					dataType : "date",
					width : "65",
					minWidth : "65",
					formatString : "yy-mm-dd"
				},
				{
					headerText : "내용",
					width : "330",
					minWidth : "330",
					style : "aui-left",
					dataField : "content"
				},
				{
					headerText : "모델명",
					width : "160",
					minWidth : "160",
					dataField : "machine_name"
				},
				{
					headerText : "총대수",
					width : "60",
					minWidth : "60",
					dataField : "total_cnt"
				},
				{
					headerText : "처리",
					width : "60",
					minWidth : "60",
					dataField : "proc_y_cnt"
				},
				{
					headerText : "임의처리",
					width : "60",
					minWidth : "60",
					dataField : "proc_p_cnt"
				},
				{
					headerText : "미처리",
					width : "60",
					minWidth : "60",
					dataField : "proc_n_cnt"
				},
				{
					headerText : "상태",
					width : "60",
					minWidth : "60",
					dataField : "campaign_status",
				}
			];
	
			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "campaign_name") {
					var param = {
							campaign_seq : event.item.campaign_seq
					};
					
					var popupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=740, left=0, top=0";
					$M.goNextPage('/serv/serv0506p01', $M.toGetParam(param), {popupStatus : popupOption});
				}
			});
	
		}
		
		// 그리드 초기화
		function destroyGrid() {
			AUIGrid.setGridData(auiGrid, []);
		};
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
									<col width="60px">
									<col width="260px">
									<col width="70px">
									<col width="120px">	
									<col width="50px">
									<col width="120px">	
									<col width="55px">
									<col width="120px">	
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<th>등록일자</th>
										<td>
											<div class="form-row inline-pd">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="요청시작일" value="${searchDtMap.s_start_dt}">
												</div>
											</div>
											<div class="col-auto text-center">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="요청종료일" value="${searchDtMap.s_end_dt}">
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
										<th>진행상태</th>
										<td>
											<select class="form-control" id="s_status_cd" name="s_status_cd">
												<option value="">- 전체 -</option>
												<option value="1">등록</option>
												<option value="2">진행</option>
												<option value="3">기간만료</option>
												<option value="4">종결</option>
											</select>
										</td>
										<th>센터</th>
										<td>
											<select class="form-control" id="s_center_org_code" name="s_center_org_code">
												<option value="">- 전체 -</option>
												<c:forEach var="item" items="${orgCenterList}">
													<option value="${item.org_code}">${item.org_name}</option>
												</c:forEach>
											</select>
										</td>
										<th>담당자</th>
										<td>
											<input type="text" class="form-control" id="s_kor_name" name="s_kor_name">
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
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
								</div>
							</div>
						</div>
	<!-- /조회결과 -->
						<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
						<div class="btn-group mt5">
							<div class="left">
								총 <strong class="text-primary" id="total_cnt">${total_cnt}</strong>건
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