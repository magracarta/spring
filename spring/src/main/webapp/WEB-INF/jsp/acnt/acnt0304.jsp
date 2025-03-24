<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 매출관리 > 렌탈매출내역관리 > null > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-10-14 18:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			fnInitDate();
			// AUIGrid 생성
			createAUIGrid();
			
			// 입력폼으로 포커스 인
			$("#s_org_name").focusin(function() {
				orgNameFormClear();
			});
			
		});
		
		// 검색조건 부서 초기화
		function orgNameFormClear() {
			$M.clearValue({field:["s_org_name", "s_org_code"]});
		}
		
		// 시작일자 세팅 현재날짜의 1달 전
		function fnInitDate() {
			/* var now = "${inputParam.s_current_dt}";
			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1)); */
		}
		
		// 조직도 팝업에서 가져온 부서코드 값 SET
		function fnSetOrgCode(result) {
			$M.setValue("s_org_code", result.org_code);
			$M.setValue("s_org_name", result.org_name);
		}
		
		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "렌탈매출내역관리", "");
		}
		
		function goSearch() {
			if ($M.validation(document.main_form) == false) {
				return;
			};
			
			if($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {				
				return;
			};

			var param = {
				"s_vat_flag" 		: $M.getValue("s_vat_flag"),
				"s_start_dt" 		: $M.getValue("s_start_dt"),
				"s_end_dt" 			: $M.getValue("s_end_dt"),
				"s_vat_treat_cd" 	: $M.getValue("s_vat_treat_cd"),
				"s_org_code_str" 	: $M.getValue("s_org_code")
			};
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

		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_start_dt", "s_end_dt"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				// No. 제거
				showRowNumColumn: true,
				headerHeight : 40,
				// 고정칼럼 카운트 지정
				editable : false,
				showFooter : true,
				footerPosition : "top",
			};
			var columnLayout = [
				{
					headerText : "발행일", 
					dataField : "inout_dt", 
					width : "70",
					minWidth : "65",
					style : "aui-center aui-popup",
					dataType : "date", 
					formatString : "yy-mm-dd",
				},
				{ 
					headerText : "부서", 
					dataField : "inout_org_name", 
					width : "70",
					minWidth : "65",
					style : "aui-center"
				},
				{ 
					headerText : "전표번호", 
					dataField : "inout_doc_no", 
					width : "120",
					minWidth : "110",
					style : "aui-center",
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name", 
					width : "120",
					minWidth : "120",
					style : "aui-center",
				},
				{ 
					headerText : "고객번호", 
					dataField : "cust_no", 
					style : "aui-center",
					visible : false,
				},
				{ 
					dataField : "inout_doc_type_cd", 
					style : "aui-center",
					visible : false,
				},
				{ 
					headerText : "업체명", 
					dataField : "breg_name", 
					width : "120",
					minWidth : "100",
					style : "aui-center",
				},
				{ 
					headerText : "모델명", 
					dataField : "machine_name", 
					width : "120",
					minWidth : "110",
					style : "aui-center"
				},
				{ 
					headerText : "차대번호", 
					dataField : "body_no", 
					width : "150",
					minWidth : "150",
					style : "aui-center"
				},
				{ 
					headerText : "렌탈기간", 
					dataField : "rental_dt_term",
					style : "aui-center",
					width : "150",
					minWidth : "150",
					dataType : "date", 
					formatString : "yyyy-mm-dd",
				},
				{ 
					headerText : "공급가<br/>(물품대-할인액-마일리지사용금액)",
					dataField : "supply_amt",
					formatString : "#,##0",
					dataType : "numeric",
					width : "200",
					minWidth : "100",
					style : "aui-right"
				},
				{ 
					headerText : "계산서일자", 
					dataField : "taxbill_dt",
					width : "80",
					minWidth : "80",
					style : "aui-center",
					dataType : "date", 
					formatString : "yy-mm-dd",
				},
				{ 
					headerText : "구분", 
					dataField : "vat_treat",
					width : "6%",
					minWidth : "80",
					style : "aui-center"
				},
				/* { 
					headerText : "처리센터", 
					dataField : "org_name",
					width : "6%",
					style : "aui-center"
				}, */
				{ 
					headerText : "처리자", 
					dataField : "mem_name",
					width : "80",
					minWidth : "80",
					style : "aui-center"
				}
			];
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "rental_dt_term",
					style : "aui-center aui-footer",
				}, 
				{
					dataField : "supply_amt",
					positionField : "supply_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				}
			];
		
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			// 발주내역 클릭시 -> 발주서상세 팝업 호출
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "inout_dt" ) {
					var param = {
						"s_cust_no"  			: event.item.cust_no,
						"s_inout_doc_type_cd" 	: event.item.inout_doc_type_cd,
						"s_body_no" 			: event.item.body_no,
						"s_start_dt" 			: event.item.inout_dt,
						"s_end_dt" 				: event.item.inout_dt,
					}
					openDealLedgerPanel($M.toGetParam(param));
				};
			});	
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
									<col width="90px">
									<col width="260px">								
									<col width="40px">
									<c:if test="${page.fnc.F00670_001 eq 'Y'}">
										<col width="250px">
									</c:if>
									<c:if test="${page.fnc.F00670_001 ne 'Y'}">
										<col width="120px">
									</c:if>
									<col width="70px">
									<col width="100px">
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<td>
											<select class="form-control" id="s_vat_flag" name="s_vat_flag">
												<option value="in">발행일자</option>
												<option value="tax">계산서일자</option>
											</select>
										</td>
										<td>
											<div class="form-row inline-pd ">
				                                <div class="col-5">
				                                   <div class="input-group">
				                                      <input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="요청 시작일" value="${searchDtMap.s_start_dt }">
				                                   </div>
				                                </div>
				                                <div class="col-auto">~</div>
				                                <div class="col-5">
				                                   <div class="input-group">
				                                      <input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="요청 종료일" value="${searchDtMap.s_end_dt }">
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
										<th>부서</th>
		                                <td>
											<c:choose>
												<c:when test="${page.fnc.F00670_001 eq 'Y'}">
													<input class="form-control" style="width: 99%;" type="text" id="s_org_code" name="s_org_code" easyui="combogrid"
													easyuiname="centerList" panelwidth="300" idfield="org_code" textfield="org_name" multi="Y"/>
												</c:when>
												<c:when test="${page.fnc.F00670_001 ne 'Y'}">
													<div class="col width100px" style="padding-right: 0;">
														<input type="text" class="form-control" value="${SecureUser.org_name}" readonly="readonly">
														<input type="hidden" value="${SecureUser.org_code}" id="s_to_warehouse_cd" name="s_to_warehouse_cd" readonly="readonly">
													</div> 
												</c:when>
											</c:choose>
											
		                                </td>
										<th>계산서구분</th>
										<td>
											<select class="form-control" name="s_vat_treat_cd" id="s_vat_treat_cd">
												<option value="">- 전체 -</option>
												<c:forEach var="list" items="${codeMap['VAT_TREAT']}">
													<option value="${list.code_value}">
														<c:choose>
															<c:when test="${list.code_value eq 'Y'}">세금계산서</c:when>
															<c:when test="${list.code_value eq 'S'}">합산발행</c:when>
															<c:when test="${list.code_value eq 'F'}">수정세금계산서</c:when>
															<c:when test="${list.code_value eq 'C'}">카드매출</c:when>
															<c:when test="${list.code_value eq 'A'}">현금영수증</c:when>
															<c:when test="${list.code_value eq 'N'}">무증빙</c:when>
														</c:choose>
													</option>
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
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
								</div>
							</div>
						</div>
	<!-- /조회결과 -->
						<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
						<div class="btn-group mt5">
							<div class="left">
								총 <strong class="text-primary" id="total_cnt">0</strong>건
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