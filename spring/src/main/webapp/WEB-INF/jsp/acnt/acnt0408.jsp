<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 정산 > 중고장비관리 > null > null
-- 작성자 : 박준영
-- 최초 작성일 : 2020-06-08 15:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
// 			fnInitDate();
			// AUIGrid 생성
			createAUIGrid();
			goSearch();
		});
		
		
		// 중고장비내역 시작일자 세팅 현재날짜의 1달 전
// 		function fnInitDate() {
// 			var now = "${inputParam.s_current_dt}";
// 			$M.setValue("s_start_search_dt", $M.addMonths($M.toDate(now), -1));
// 		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				// No. 제거
				showRowNumColumn: true,
				editable : false,
				showFooter : true,
				footerPosition : "top",
				enableMovingColumn : false
			};
			var columnLayout = [
				{
					headerText : "관리번호", 
					dataField : "display_no", 
					width : "70",
					minWidth : "65",
					style : "aui-center aui-popup",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
	                  var ret = "";
	                  if (value != null && value != "") {
	                     ret = value.split("-");
	                     ret = ret[0]+"-"+ret[1];
	                     ret = ret.substr(4, ret.length);
	                  }
	                   return ret; 
	               }, 
				},
				{
					headerText : "관리번호", 
					dataField : "machine_used_no", 
					visible: false
				},
				{ 
					headerText : "모델명", 
					dataField : "machine_name", 
					width : "90",
					minWidth : "65",
					style : "aui-left"
				},
				{ 
					headerText : "차대번호", 
					dataField : "body_no", 
					width : "160",
					minWidth : "110",
					style : "aui-center"
				},
				{ 
					headerText : "전차주명", 
					dataField : "old_cust_name", 
					width : "65",
					minWidth : "65",
					style : "aui-center"
				},
				{ 
					headerText : "담당자", 
					dataField : "buy_mem_name", 
					width : "60",
					minWidth : "60",
					style : "aui-center"
				},
				{ 
					headerText : "매입처", 
					dataField : "mng_org_name", 
					width : "80",
					minWidth : "40",
					style : "aui-center"
				},
				{ 
					headerText : "매입일", 
					dataField : "taxbill_dt", 
					width : "65",
					minWidth : "65",
					dataType : "date",  
					formatString : "yy-mm-dd",					
					style : "aui-center"
				},
				{ 
					headerText : "매입가", 
					dataField : "used_price", 
					width : "90",
					minWidth : "65",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right"
				},
				{ 
					headerText : "품의가", 
					dataField : "agent_price", 
					width : "90",
					minWidth : "65",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right"
				},
				{ 
					headerText : "손익", 
					dataField : "machine_used_loss_amt", 
					width : "90",
					minWidth : "65",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right"
				},
				{ 
					headerText : "판매자", 
					dataField : "sale_mem_name", 
					width : "65",
					minWidth : "65",
					style : "aui-center"
				},
				{ 
					headerText : "판매일", 
					dataField : "sale_dt", 
					width : "65",
					minWidth : "65",
					dataType : "date",  
					formatString : "yy-mm-dd",					
					style : "aui-center"
				},
				{ 
					headerText : "출하일", 
					dataField : "out_dt", 
					width : "65",
					minWidth : "65",
					dataType : "date",  
					formatString : "yy-mm-dd",					
					style : "aui-center"
				},
				{ 
					headerText : "처리구분", 
					dataField : "used_buy_status_name", 
					width : "65",
					minWidth : "65",
					style : "aui-center"
				},
				{ 
					headerText : "관리사항", 
					dataField : "desc_text", 
					width : "170",
					minWidth : "30",
					style : "aui-left"
				}
			];
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "taxbill_dt"
				},
				{
					dataField : "used_price",
					positionField : "used_price",
					operation : "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"	
				},
				{
					dataField : "agent_price",
					positionField : "agent_price",
					operation : "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"		
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// AUIGrid.setFixedColumnCount(auiGrid, 5);
			// 푸터 객체 세팅
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "display_no" ) {
					var params = {
							"machine_used_no" : event.item.machine_used_no 
					};
					
					var popupOption = "";
					$M.goNextPage('/acnt/acnt0408p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});	
		}
		
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_used_buy_status_cd"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}
		
		function goSearch() {
			if($M.checkRangeByFieldName("s_start_search_dt", "s_end_search_dt", true) == false) {				
				return;
			}; 
			
			var param = {
					
				s_start_search_dt : $M.getValue("s_start_search_dt"),
				s_end_search_dt : $M.getValue("s_end_search_dt"),
				s_dt_type : $M.getValue("s_dt_type"),
				s_used_buy_status_cd : $M.getValue("s_used_buy_status_cd"),
				s_mng_org_code: $M.getValue("s_mng_org_code"),
				s_sort_key : "machine_used_no ",
				s_sort_method : "desc"
			};
			//관리부만 전체 매입처 조회 가능
			if("${page.fnc.F00746_001}" != "Y" && $M.getValue("s_mng_org_code") == "")
			{
				alert("매입처 정보가 없습니다");
				return;
			}
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}
			
		// 엑셀 다운로드
		function fnDownloadExcel() {
			var exportProps = {
			         // 제외항목
			  };
		  	fnExportExcel(auiGrid, "중고장비관리", exportProps);
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
								<col width="85px">
								<col width="260px">								
								<col width="65px">
								<col width="100px">
								<col width="65px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<td>
										<select id="s_dt_type" name="s_dt_type" class="form-control">
											<option value="all_search" >- 전체 -</option>
											<option value="sale_dt" >판매일자</option>
											<option value="taxbill_dt" >매입일자</option>
											<option value="out_dt" >출하일자</option>
											
										</select>
									</td>
									<td>
										<div class="form-row inline-pd ">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_search_dt" name="s_start_search_dt" dateformat="yyyy-MM-dd" alt="시작일" value="${searchDtMap.s_start_dt}" >
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_search_dt" name="s_end_search_dt" dateformat="yyyy-MM-dd" alt="종료일" value="${searchDtMap.s_end_dt}">
												</div>
											</div>
											<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
				                     		<jsp:param name="st_field_name" value="s_start_search_dt"/>
				                     		<jsp:param name="ed_field_name" value="s_end_search_dt"/>
				                     		<jsp:param name="click_exec_yn" value="Y"/>
				                     		<jsp:param name="exec_func_name" value="goSearch();"/>
				                     		</jsp:include>	
										</div>
									</td>
									<th>처리구분</th>
									<td>
										<select id="s_used_buy_status_cd" name="s_used_buy_status_cd" class="form-control"  >
											<!-- //관리부만 전체 처리구분 조회 가능 -->			
											<c:choose>											
											    <c:when test="${page.fnc.F00746_001 eq 'Y'}">
													<option value="">- 전체 -</option>
													<c:forEach items="${codeMap['USED_BUY_STATUS']}" var="item">
														<option value="${item.code_value}">${item.code_name}</option>
													</c:forEach>
											    </c:when>
											    <c:otherwise>
											      	<c:forEach items="${codeMap['USED_BUY_STATUS']}" var="item">
											      		<c:if test="${item.code_value eq '3'}">
															<option value="${item.code_value}">${item.code_name}</option>
														</c:if>													
													</c:forEach>
											    </c:otherwise>																			
											</c:choose>										
										</select>
									</td>
									<th>매입처</th>
									<td>
										<select name="s_mng_org_code" id="s_mng_org_code" class="form-control"  alt="중고장비 매입처">
											<c:forEach items="${mngOrgCdList}" var="item">
												<option value="${item.org_code}">${item.org_name}</option>		
											</c:forEach>
										</select>
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;"  onclick="javascript:goSearch();" >조회</button>
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
							총 <strong class="text-primary"  id="total_cnt" >0</strong>건
						</div>	
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
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