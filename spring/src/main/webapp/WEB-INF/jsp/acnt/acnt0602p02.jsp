<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 자산 > 휴가원관리 > null > 휴가원상세
-- 작성자 : 손광진
-- 최초 작성일 : 2020-04-21 17:38:26
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			createAUIGrid();
		});
		
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "mem_holiday_seq",
				height : 550,
				showRowNumColumn: true,
				fillColumnSizeMode : false
			};
			var columnLayout = [
				{    
					headerText : "종류", 
					dataField : "holiday_type_name", 
					width : "8%",
					style : "aui-center aui-popup",
				},
				{    
					headerText : "기간(From)", 
					dataField : "start_dt", 
					dataType : "date",   
					formatString : "yyyy-mm-dd",
					width : "8%",
					style : "aui-center",
				},
				{    
					headerText : "기간(To)", 
					dataField : "end_dt", 
					dataType : "date",   
					formatString : "yyyy-mm-dd",
					width : "8%",
					style : "aui-center",
				},
				{    
					headerText : "일수", 
					dataField : "day_cnt", 
					width : "5%",
					style : "aui-center",
				},
				{    
					headerText : "사유", 
					dataField : "content", 
					width : "25%",
					style : "aui-left",
				},
				{    
					headerText : "작성", 
					dataField : "apply_mem_name", 
					width : "5%",
					style : "aui-center",
				},
				{    
					headerText : "상태", 
					dataField : "appr_proc_status_name", 
					width : "5%",
					style : "aui-center",
				},
				{    
					headerText : "신청일", 
					dataField : "appr_req_dt", 
					dataType : "date",   
					formatString : "yyyy-mm-dd",
					width : "10%",
					style : "aui-center",
				},
				{    
					headerText : "결재일", 
					dataField : "last_proc_dt", 
					dataType : "date",   
					formatString : "yyyy-mm-dd",
					width : "10%",
					style : "aui-center",
				},
				{    
					headerText : "연락처", 
					dataField : "contact_no", 
					width : "10%",
					style : "aui-center",
				},
				{
					headerText : "결재", 
					dataField : "last_proc_mem_name", 
					style : "aui-center",
				}
			];
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, listJson);
			$("#auiGrid").resize();
			
			// 휴가원 상세
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "holiday_type_name") {
					var param = {
						"mem_holiday_seq" 	: event.item.mem_holiday_seq,
					};
					var popupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1350, height=470, left=0, top=0";
					$M.goNextPage("/mmyy/mmyy0106p02", $M.toGetParam(param), {popupStatus : popupOption});
				};		      
			});
			
		}
		
		function enter(fieldObj) {
			var field = ["s_kor_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}
		
		function fnClose() {
			window.close();
		}
	</script>
</head>
<body class="bg-white class">
	<form id="main_form" name="main_form">
	<input type="hidden" id="s_year" name="s_year" value="${inputParam.s_year}">
	<input type="hidden" id="s_mem_no" name="s_mem_no" value="${inputParam.s_mem_no}">
	<input type="hidden" id="s_mem_no" name="s_mem_no" value="${inputParam.org_name}">
<%-- 	<input type="hidden" id="s_year" name="s_year" value="${inputParam.holiday_year}"> --%>
<%-- 	<input type="hidden" id="s_mem_no" name="s_mem_no" value="${result.mem_no}"> --%>
		<div class="layout-box">
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
						<div class="title-wrap">
							<div class="left">
								<h4>${inputParam.s_year}년</h4>					
								<div class="com-info">${map.org_name}</div>
								<div class="com-info">${map.kor_name}</div>
							</div>
						</div>
						<table class="table-border mt5">
							<colgroup>
								<col width="90px">
								<col width="">
								<col width="90px">
								<col width="">
								<col width="90px">
								<col width="">
								<col width="90px">
								<col width="">
								<col width="90px">
								<col width="">
								<col width="90px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th class="text-right">국내출장</th>
									<td class="text-center">${result.in_biz_trip_day}</td>
									<th class="text-right">국외출장</th>
									<td class="text-center">${result.over_biz_trip_day}</td>
									<th class="text-right">종일휴가</th>
									<td class="text-center">${result.all_vacation_day}</td>
									<th class="text-right">오전휴가</th>
									<td class="text-center">${result.am_vacation_day}</td>
									<th class="text-right">오후휴가</th>
									<td class="text-center">${result.pm_vacation_day}</td>
									<th class="text-right">공가</th>
									<td class="text-center">${result.official_vacation_day}</td>
								</tr>
								<tr>
									<th class="text-right">특별휴가</th>
									<td class="text-center">${result.spc_vacation_day}</td>
									<th class="text-right">무급휴가</th>
									<td class="text-center">${result.unpaid_vacation_day}</td>
									<th class="text-right">연간휴가일수</th>
									<td class="text-center">${result.issue_cnt}</td>
									<th class="text-right">연간사용일수</th>
									<td class="text-center">${result.use_day_cnt}</td>
									<th class="text-right">미결신청일수</th>
									<td class="text-center">${result.ing_day_cnt}</td>
									<th class="text-right">휴가잉여일수</th>
									<td class="text-center">${result.unuse_day_cnt}</td>
								</tr>
							</tbody>
						</table>
						<div style="margin-top: 5px; height: 300px;" id="auiGrid"></div>
					</div>
					<!-- /폼테이블-->					
					<div class="btn-group mt10">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">${total_cnt}</strong>건
						</div>						
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
		        </div>
		    </div>
			<!-- /팝업 -->
		</div>	
	</form>
</body>
</html>