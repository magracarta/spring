<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객현황 > 견적서관리 > 수주/정비/렌탈 견적서 > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2023-08-18 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		<%-- 여기에 스크립트 넣어주세요. --%>
		$(document).ready(function() {
			if ( parent.fnStyleChange )
				parent.fnStyleChange('N', 'search');

			createAUIGrid();
			// fnInit();
		});
		
		function enter(fieldObj) {
			if (fieldObj.name == "s_cust_name") {
				goSearch();
			}
		} 
		
		function fnInit() {
// 			var now = "${inputParam.s_current_dt}";
// 			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -3));

		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				editable : false,
				rowIdField: "_$uid",
				// rowIdField : "rfq_no",
				// showRowNumColumn: false,
				enableCellMerge : true,
			};
			var columnLayout = [
				{
					dataField : "rfq_no",
					visible : false
				},
				{
					dataField : "cust_no",
					visible : false
				},
				{
					headerText : "견적서번호", 
					dataField : "rfq_no_1", 
					width : "90", 
					minWidth : "80",
					labelFunction : function(rowIndex, columnIndex, value) {
						return value.substr(4, value.length);
					},
					style : "aui-center",
					cellMerge : true
				},
				{
					headerText : "차수", 
					dataField : "rfq_no_2", 
					width : "3%", 
					minWidth : "35",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value) {
						return value.replace(/(^0+)/, "");
					}
				},
				{ 
					headerText : "처리번호", 
					dataField : "process_no",   
					width : "8%", 
					minWidth : "60",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						var ret = "";
						if (value != null && value != "") {
							ret = value.split("-");
							ret = ret[0]+"-"+ret[1];
							ret = ret.substr(4, ret.length);
						}
					    return ret; 
					}, 
					style : "aui-center",
				},
				{ 
					headerText : "등록일시", // 견적일자에 시간 저장안해서 등록일시로 변경 
					dataField : "reg_date",
					dataType : "date",   
					width : "130", 
					minWidth : "130",
					style : "aui-center",
					formatString : "yy-mm-dd HH:MM:ss",
				},
				{
					headerText : "구분", 
					dataField : "rfq_type_name", 
					width : "35", 
					minWidth : "35",
					style : "aui-center"
				},
				{ 
					headerText : "유효기간", 
					dataField : "expire_dt",
					dataType : "date",   
					width : "7%", 
					minWidth : "75",
					style : "aui-center",
					formatString : "yy-mm-dd",
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name",   
					width : "8%",
					minWidth : "120",
					style : "aui-center aui-popup",
				},
				{ 
					headerText : "휴대폰", 
					dataField : "hp_no",  
					width : "10%", 
					minWidth : "105",
					style : "aui-center"
				},
				/* { 
					headerText : "이메일", 
					dataField : "email",  
					width : "10%", 
					style : "aui-center"
				}, */
				{ 
					headerText : "견적금액", 
					dataField : "rfq_amt",  
					dataType : "numeric",
					width : "7%",
					minWidth : "130",
					formatString : "#,##0",
					style : "aui-right",
				},
				{ 
					headerText : "할인금액", 
					dataField : "discount_amt",  
					dataType : "numeric",
					width : "7%",
					minWidth : "130",
					formatString : "#,##0",
					style : "aui-right",
					labelFunction : function(rowIndex, columnIndex, value) {
						var ret = "";
						if (value != null && value != "0") {
							ret = $M.setComma(value);
						} else {
							ret = "0";
						}
						return ret;
					}
				},	
				{
					headerText : "견적내역", 
					dataField : "rfq_contents", 
					style : "aui-left"
				},
				{
					headerText : "부서", 
					dataField : "rfq_org_name", 
					width : "7%", 
					minWidth : "70",
					style : "aui-center"
				},
				{
					headerText : "견적자", 
					dataField : "rfq_mem_name", 
					width : "70 ", 
					minWidth : "70",
					style : "aui-center"
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			// AUIGrid.setFixedColumnCount(auiGrid, 8);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "cust_name") {
					var type = event.item.rfq_type_name;
					var param = {
							rfq_no : event.item.rfq_no,
							cust_no : event.item.cust_no
					}
					if (event.item.process_no != null && event.item.process_no != "") {
						param['disabled_yn'] = 'Y'
					}
					var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=950, left=0, top=0";
					if(type == "장비") {						
						$M.goNextPage('/cust/cust0107p01', $M.toGetParam(param), {popupStatus : poppupOption});
					}
					if(type == "수주") {
						$M.goNextPage('/cust/cust0107p02', $M.toGetParam(param), {popupStatus : poppupOption});							
					}
					if(type == "정비") {
						$M.goNextPage('/cust/cust0107p03', $M.toGetParam(param), {popupStatus : poppupOption});
					}
					if(type == "렌탈") {
						$M.goNextPage('/cust/cust0107p04', $M.toGetParam(param), {popupStatus : poppupOption});							
					}
				}
			});
		}
		
		
		function goAdd() {
			$M.goNextPage("/cust/cust010702");
<%--			<c:if test="${SecureUser.org_type ne 'AGENCY'}">--%>
<%--			<c:if test="${page.fnc.F00033_001 ne 'Y'}">--%>
<%--				// 수주견적서--%>
<%--				$M.goNextPage("/cust/cust010702");--%>
<%--			</c:if>--%>
<%--			<c:if test="${SecureUser.org_type eq 'AGENCY'}">--%>
<%--			<c:if test="${page.fnc.F00033_001 eq 'Y'}">--%>
				// 장비견적서
				// $M.goNextPage("/cust/cust010701");
<%--			</c:if>--%>
		}
		
		function goSearch() {
			if ($M.validation(document.main_form) == false) {
				return;
			};
			if($M.checkRangeByFieldName('s_start_dt', 's_end_dt', true) == false) {				
				return;
			}; 
			var param = {
				s_start_dt : $M.getValue("s_start_dt"),
				s_end_dt : $M.getValue("s_end_dt"),
				// s_cust_no : $M.getValue("s_cust_no"),
				s_cust_name : $M.getValue("s_cust_name"),
				s_rfq_type_cd : $M.getValue("s_rfq_type_cd"),
				s_sort_key : "rfq_no desc, reg_date",
				s_sort_method : "desc",
				s_masking_yn : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N"
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			// $M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
			$M.goNextPageAjax("/cust/cust0107/search", $M.toGetParam(param), {method : 'get'},
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
			  // 엑셀 내보내기 속성
			  var exportProps = {};
			  fnExportExcel(auiGrid, "견적서내역", exportProps);
		}
	
	</script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
<%--			<div class="content-box">--%>
<!-- 메인 타이틀 -->
<%--				<div class="main-title">--%>
<%--					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>--%>
<%--				</div>--%>
<!-- /메인 타이틀 -->
<%--				<div class="contents">--%>
<!-- 기본 -->					
					<div class="search-wrap mt10">
						<table class="table">
							<colgroup>
								<col width="60px">
								<col width="260px">
								<col width="50px">
								<col width="100px">
								<col width="60px">
								<col width="70px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>등록일</th>
									<td>
										<div class="form-row inline-pd ">
			                                 <div class="col-5">
			                                    <div class="input-group">
			                                       <input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="시작일" value="${searchDtMap.s_start_dt}" >
			                                    </div>
			                                 </div>
			                                 <div class="col-auto">~</div>
			                                 <div class="col-5">
			                                    <div class="input-group">
			                                       <input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="종료일" value="${searchDtMap.s_end_dt}">
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
									<th>고객명</th>
									<td>
										<input type="text" class="form-control" name="s_cust_name" id="s_cust_name">
										<%-- <jsp:include page="/WEB-INF/jsp/common/searchCust.jsp">
				                     		<jsp:param name="required_field" value=""/>
			 	                     		<jsp:param name="execFuncName" value=""/>
			 	                     		<jsp:param name="focusInFuncName" value=""/>
			 	                     		<jsp:param name="focusInClearYn" value="Y"/>
				                     	</jsp:include> --%>
									</td>
									<th>구분</th>
									<td>
										<select class="form-control" id="s_rfq_type_cd" name="s_rfq_type_cd">
<%--											<c:if test="${SecureUser.org_type ne 'AGENCY'}">--%>
											<c:if test="${page.fnc.F00033_001 ne 'Y'}">
												<option value="">- 전체 -</option>
												<c:forEach var="item" items="${codeMap['RFQ_TYPE']}">
													<c:if test="${item.code_value ne 'MACHINE'}"><option value="${item.code_value}">${item.code_name}</c:if></option>
												</c:forEach>
											</c:if>
<%--											<c:if test="${SecureUser.org_type eq 'AGENCY'}">--%>
											<c:if test="${page.fnc.F00033_001 eq 'Y'}">
												<option value="MACHINE" selected="selected">장비</option>
											</c:if>
										</select>
									</td>									
									<td class="">
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>
								</tr>								
							</tbody>
						</table>
					</div>
<!-- /기본 -->	
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>견적서내역</h4>
						<div class="btn-group">
							<div class="right">
							<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
							<div class="form-check form-check-inline">
								<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
								<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
							</div>
							</c:if>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->					

					<div id="auiGrid" style="height:555px; margin-top: 5px;"></div>

<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>						
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
<%--				</div>--%>
<%--			</div>	--%>
<%--			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>	--%>
		</div>
<!-- /contents 전체 영역 -->	
</div>
</form>
</body>
</html>