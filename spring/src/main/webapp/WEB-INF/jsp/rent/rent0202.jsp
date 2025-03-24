<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈대장 > 어태치먼트대장 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-05-21 20:04:45
-- 렌탈어태치 매입처는 수기로 등록한것만 나오고, 출하할때 등록된것은 안나온다.
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
		});

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				enableFilter :true,
				rowIdField : "_$uid",
				showRowNumColumn: true
			};
			var columnLayout = [
				{ 
					headerText : "관리센터", 
					dataField : "mng_org_name",
					width : "75", 
					minWidth : "60",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "소유센터", 
					dataField : "own_org_name",
					width : "75", 
					minWidth : "60",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "관리번호", 
					dataField : "rental_attach_no", 
					width : "100", 
					minWidth : "45",
					style : "aui-center  aui-popup",
					filter : {
						showIcon : true
					}
				},
				/* {
					headerText : "매입처", 
					dataField : "client_name", 
					width : "100", 
					minWidth : "45",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				}, */
				{ 
					headerText : "어태치먼트명", 
					dataField : "attach_name",  
					width : "100", 
					minWidth : "45",
					style : "aui-left",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "부품번호", 
					dataField : "part_no", 
					width : "100", 
					minWidth : "45",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "일련번호", 
					dataField : "product_no", 
					width : "100", 
					minWidth : "45",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "매입일자", 
					dataField : "buy_dt", 
					dataType : "date",  
					dataInputString : "yyyymmdd",
					formatString : "yy-mm-dd",
					width : "75", 
					minWidth : "75",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "판매일자",
					dataField : "sale_dt",
					dataType : "date",
					dataInputString : "yyyymmdd",
					formatString : "yy-mm-dd",
					width : "75",
					minWidth : "75",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "매입가", 
					dataField : "buy_price", 
					style : "aui-right",
					dataType : "numeric",
					width : "80", 
					minWidth : "45", 
					formatString : "#,##0",
					filter : {
						showIcon : true
					}
				},
        {
          headerText : "판매일자",
          dataField : "sale_dt",
          dataType : "date",
          dataInputString : "yyyymmdd",
          formatString : "yy-mm-dd",
          width : "75",
          minWidth : "75",
          style : "aui-center",
          filter : {
            showIcon : true
          }
        },
				{ 
					headerText : "이자금액", 
					dataField : "interest_amt", 
					style : "aui-right",
					dataType : "numeric",
					width : "70", 
					minWidth : "45",
					formatString : "#,##0",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "수리금액", 
					dataField : "rental_repair_price",
					style : "aui-right",
					dataType : "numeric",
					width : "70", 
					minWidth : "45",
					formatString : "#,##0",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "최종가액", 
					dataField : "final_attach_price", 
					style : "aui-right",
					dataType : "numeric",
					width : "95", 
					minWidth : "45", 
					formatString : "#,##0",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "렌탈매출", 
					dataField : "rental_sale", 
					style : "aui-right",
					dataType : "numeric",
					width : "70", 
					minWidth : "45", 
					formatString : "#,##0",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "최소판가", 
					dataField : "min_sale_price", 
					style : "aui-right",
					dataType : "numeric",
					width : "70", 
					minWidth : "45", 
					formatString : "#,##0",
					filter : {
						showIcon : true
					}
				},
			];
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			
			// 상세팝업
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				//관리번호를 선택할 경우 
				if(event.dataField == "rental_attach_no" ) {
					var params = {rental_attach_no : event.item.rental_attach_no};
					var popupOption = "scrollbars=no, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=350, left=0, top=0";
					$M.goNextPage('/rent/rent0202p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
	
			});	
		}
	
		function goSearch() {
			var param = {
				"s_start_buy_dt" : $M.getValue("s_start_buy_dt")
				, "s_end_buy_dt" : $M.getValue("s_end_buy_dt")
				, "s_client_name" : $M.getValue("s_client_name")
// 				, "s_part_name" : $M.getValue("__part_name")
				, "s_part_no" : $M.getValue("s_part_no")
				, "s_mng_org_code" : $M.getValue("s_mng_org_code")
				, "s_own_org_code" : $M.getValue("s_own_org_code")
				, "s_sale_include_yn" : $M.getValue("s_sale_include_yn") == "Y" ? "Y" : "N"
				, "s_sale_yn" : $M.getValue("s_sale_yn") == "Y" ? "Y" : "N"
				, "s_sort_key" : "buy_dt desc,"
				, "s_sort_method" : "a.rental_attach_no desc"
			};
			_fnAddSearchDt(param, 's_start_buy_dt', 's_end_buy_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					}
				}
			);
		}
	
		function fnDownloadExcel() {
			var exportProps = {};
			fnExportExcel(auiGrid, "어태치먼트대장", exportProps);
	    }
			
		// 페이지 이동
		function goNew() {
 			$M.goNextPage("/rent/rent020201");
		}
		
		// 엔터
		function enter(fieldObj) {
	       var field = ["s_client_name","s_part_name"];
	       $.each(field, function() {
	          if (fieldObj.name == this) {
	             goSearch(document.main_form);
	          }
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
	<!-- 기본 -->					
				<div class="search-wrap">				
					<table class="table">
						<colgroup>
							<col width="70px">
							<col width="260px">							
							<col width="55px">
							<col width="100px">	
							<col width="10px">
							<col width="280px">	
							<col width="65px">
							<col width="90px">
							<col width="65px">
							<col width="90px">
							<col width="90px">
							<col width="90px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th>매입일자</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_start_buy_dt" name="s_start_buy_dt" dateformat="yyyy-MM-dd" alt="매입일자" value="">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_end_buy_dt" name="s_end_buy_dt" dateformat="yyyy-MM-dd" alt="매입일자" value="">
											</div>
										</div>
										<div>
											<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
					                     		<jsp:param name="st_field_name" value="s_start_buy_dt"/>
					                     		<jsp:param name="ed_field_name" value="s_end_buy_dt"/>
					                     		<jsp:param name="click_exec_yn" value="Y"/>
					                     		<jsp:param name="exec_func_name" value="goSearch();"/>
					                     	</jsp:include>
				                     	</div>
									</div>
								</td>
								<th>매입처</th>
								<td>
									<input type="text" class="form-control" id="s_client_name" name="s_client_name" value="">
								</td>
								<th><!-- 어태치먼트명/모델명(품번) --></th>
								<td>
									<jsp:include page="/WEB-INF/jsp/common/searchPart.jsp">
			                     		<jsp:param name="required_field" value=""/>
			                     	</jsp:include>																		
								</td>
								<th>관리센터</th>
								<td>
									<select class="form-control" id="s_mng_org_code" name="s_mng_org_code">
										<option value="">- 전체 -</option>
										<c:forEach var="item" items="${orgCenterList}">
											<option value="${item.org_code}"
												<c:if test="${SecureUser.org_type eq 'CENTER' && SecureUser.org_code eq item.org_code}">selected</c:if>
												>${item.org_name}</option>
										</c:forEach>
										<option value="5010">서비스지원</option>
									</select>
								</td>
								<th>소유센터</th>
								<td>
									<select class="form-control" id="s_own_org_code" name="s_own_org_code">
										<option value="">- 전체 -</option>
										<c:forEach var="item" items="${orgCenterList}">
											<option value="${item.org_code}">${item.org_name}</option>
										</c:forEach>
										<option value="5010">서비스지원</option>
									</select>
								</td>	
								<td>
									<div class="form-check form-check-inline pl5">
										<label><input class="form-check-input" style="margin: 2px .3125rem 1px 0" type="checkbox" id="s_sale_include_yn" name="s_sale_include_yn" value="Y" onclick="javascript:goSearch()">판매포함</label>
									</div>
								</td>
<%--								2024-05-23 황빛찬 (Q&A:22777) 판매일자 추가로인하여 검색조건 추가--%>
								<td>
									<div class="form-check form-check-inline pl5">
										<label><input class="form-check-input" style="margin: 2px .3125rem 1px 0" type="checkbox" id="s_sale_yn" name="s_sale_yn" value="Y" onclick="javascript:goSearch()">판매완료</label>
									</div>
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()" >조회</button>
								</td>									
							</tr>				
						</tbody>
					</table>					
				</div>
	<!-- /기본 -->	
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
				<div  id="auiGrid"  style="margin-top: 5px; height: 555px;"></div>
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
			</div>
		</div>
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>			
	</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>