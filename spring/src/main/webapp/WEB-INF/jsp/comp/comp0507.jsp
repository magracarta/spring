<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 장비연관팝업 > 장비연관팝업 > null > 렌탈장비대장
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-07-17 14:02:27
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
				rowIdField : "row",
				showRowNumColumn: true
			};
			var columnLayout = [
				{ 
					headerText : "메이커", 
					dataField : "maker_name", 
					width : "5%", 
					style : "aui-center"
				},
				{
					headerText : "모델명", 
					dataField : "machine_name", 
					width : "5%", 
					style : "aui-center"
				},
				{ 
					headerText : "차대번호", 
					dataField : "body_no", 
					dataType : "date",  
					width : "12%", 
					style : "aui-center"
				},
				{ 
					headerText : "엔진번호", 
					dataField : "engine_no_1", 
					width : "5%", 
					style : "aui-center",
				},
				{ 
					headerText : "제조연식", 
					dataField : "made_dt", 
					dataType : "date",  
					formatString : "yyyy",
					width : "5%", 
					style : "aui-center",
				},
				{ 
					headerText : "가동시간", 
					dataField : "op_hour", 
					width : "5%", 
					style : "aui-center",
					dataType : "numeric"
				},
				{ 
					headerText : "매입일자", 
					dataField : "buy_dt",
					dataType : "date",  
					dataInputString : "yyyymmdd",
					formatString : "yyyy-mm-dd",
					width : "6%", 
					style : "aui-center"
				},
				{ 
					headerText : "매입종류", 
					dataField : "buy_type_name", 
					width : "4%", 
					style : "aui-center"
				},
				{ 
					headerText : "판매가격", 
					dataField : "buy_price",
					width : "7%", 
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "GPS", 
					dataField : "gps_no", 
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						var ret = value;
						if (item.sar != null && item.sar != "") {
							ret = "SA-R";
						}
						return ret;
					},
					width : "8%", 
					style : "aui-center"
				},
				{ 
					headerText : "번호판종류", 
					dataField : "mreg_no_type_name", 
					width : "5%", 
					style : "aui-center"
				},
				{ 
					headerText : "번호판번호", 
					dataField : "mreg_no", 
					width : "8%", 
					style : "aui-center"
				},
				{ 
					headerText : "판매일자", 
					dataField : "sale_dt",
					dataType : "date",  
					dataInputString : "yyyymmdd",
					formatString : "yyyy-mm-dd",
					width : "6%", 
					style : "aui-center"
				},
				{ 
					headerText : "판매가격", 
					dataField : "sale_price",
					width : "7%", 
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "판매수익", 
					dataField : "sale_profit_amt",
					formatString : "yyyy-mm-dd",
					width : "7%", 
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "관리센터", 
					dataField : "mng_org_name",
	//					width : "5%", 
					style : "aui-center"
				},
				{ 
					dataField : "rental_machine_no",
					visible : false
				},
				{
					dataField : "gps_type_cd",
					visible : false
				},
				{
					dataField : "contract_no",
					visible : false
				},
				{
					dataField : "sar",
					visible : false
				}
			];
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				// Row행 클릭 시 반영
				try{
					opener.${inputParam.parent_js_name}(event.item);
					window.close();	
				} catch(e) {
					alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
				};
			});
			$("#auiGrid").resize();
		}
		
		// 조회
		function goSearch() {
			var param = {
				"s_start_buy_dt" : $M.getValue("s_start_buy_dt")
				, "s_end_buy_dt" : $M.getValue("s_end_buy_dt")
				, "s_maker_cd" : $M.getValue("s_maker_cd")
				, "s_machine_plant_seq" : $M.getValue("s_machine_plant_seq")
				, "s_body_no" : $M.getValue("s_body_no")
				, "s_buy_type_un" : $M.getValue("s_buy_type_un")
				, "s_made_dt" : $M.getValue("s_made_dt")
				, "s_mng_org_code" : $M.getValue("s_mng_org_code")
				, "s_machine_name" : $M.getValue("s_machine_name")
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					}
				}
			);
		}
			
		// 엑셀다운로드
		function fnDownloadExcel() {
			var exportProps = {};
			fnExportExcel(auiGrid, "렌탈장비대장", exportProps);
	    }
		
		// 엔터
		function enter(fieldObj) {
	       var field = ["s_body_no", "s_machine_name"];
	       $.each(field, function() {
	          if (fieldObj.name == this) {
	              goSearch();
	          }
	       });
	    }
		
		function fnClose() {
			window.close();
		}
		
	</script>
</head>
<body class="bg-white" style="min-width: 1200px">
<form id="main_form" name="main_form">
<!-- 팝업 -->
	<div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	  
<!-- 검색조건 -->
			<div class="search-wrap">
				<table class="table">
					<colgroup>
						<col width="55px">
						<col width="260px">							
						<col width="60px">
						<col width="80px">	
						<col width="60px">
						<col width="200px">	
						<col width="55px">
						<col width="70px">	
						<col width="55px">
						<col width="70px">
						<col width="35px">
						<col width="65px">
						<col width="60px">
						<col width="60px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th>매입일자</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width110px">
										<div class="input-group">
<%-- 											<input type="text" class="form-control border-right-0 calDate" id="s_start_buy_dt" name="s_start_buy_dt" dateformat="yyyy-MM-dd" alt="요청시작일" value="${inputParam.s_before_one_year}"> --%>
											<input type="text" class="form-control border-right-0 calDate" id="s_start_buy_dt" name="s_start_buy_dt" dateformat="yyyy-MM-dd" alt="요청시작일" value="">
										</div>
									</div>
									<div class="col-auto text-center">~</div>
									<div class="col width120px">
										<div class="input-group">
<%-- 											<input type="text" class="form-control border-right-0 calDate" id="s_end_buy_dt" name="s_end_buy_dt" dateformat="yyyy-MM-dd" alt="요청종료일" value="${inputParam.s_current_dt}"> --%>
											<input type="text" class="form-control border-right-0 calDate" id="s_end_buy_dt" name="s_end_buy_dt" dateformat="yyyy-MM-dd" alt="요청종료일" value="">
										</div>
									</div>
								</div>
							</td>
							<th>메이커</th>
							<td>
								<select class="form-control" id="s_maker_cd" name="s_maker_cd">
									<option value="">- 전체 -</option>
									<c:forEach items="${codeMap['MAKER']}" var="item">
										<c:if test="${item.code_v1 eq 'Y' && item.code_v2 eq 'Y'}">
											<option value="${item.code_value}" <c:if test="${result.maker_cd == item.code_value}">selected</c:if>>${item.code_name}</option>
										</c:if>
									</c:forEach>
								</select>
							</td>
							<th>모델명</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-8">
										<input type="text" class="form-control" id="s_machine_name" name="s_machine_name" size="20" maxlength="20">
									</div>
								</div>
							</td>
							<th>차대번호</th>
							<td>
								<input type="text" class="form-control" id="s_body_no" name="s_body_no">
							</td>
							<th>매입종류</th>
							<td>
								<select class="form-control" id="s_buy_type_un" name="s_buy_type_un">
									<option value="">- 전체 -</option>
									<option value="U">중고</option>
									<option value="N">신차</option>
								</select>
							</td>
							<th>연식</th>
							<td>
								<select class="form-control" id="s_made_dt" name="s_made_dt">
									<option value="">- 전체 -</option>
									<option value="2">2년이하</option>
									<option value="3~4">3~4년식</option>
									<option value="5~6">5~6년식</option>
									<option value="7">7년 이상</option>
								</select>
							</td>
							<th>관리센터</th>
							<td>
								<select class="form-control" id="s_mng_org_code" name="s_mng_org_code">
									<option value="">- 전체 -</option>
									<c:forEach var="item" items="${orgCenterList}">
										<option value="${item.org_code}">${item.org_name}</option>
									</c:forEach>
								</select>
							</td>									
							<td>
								<button type="button" class="btn btn-important" style="width: 50px;"   onclick="javascript:goSearch()"   >조회</button>
							</td>									
						</tr>												
					</tbody>
				</table>
			</div>
<!-- /검색조건 -->
<!-- 검색결과 -->
			<div id="auiGrid" class="mt10" style="width: 100%;height: 600px;"></div>
			<div class="btn-group mt5">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>						
				<div class="right">
					<!-- 이렇게 쓰지마세요!  -->
					<!-- <button class="btn btn-info" onclick="javascript:fnClose()">닫기</button> -->
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>			
<!-- /검색결과 -->
        </div>
    </div>	
</form>
</body>
</html>