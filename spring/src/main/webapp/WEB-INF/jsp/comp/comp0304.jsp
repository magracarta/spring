<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 고객연관팝업 > 고객연관팝업 > null > 매입처조회
-- 작성자 : 강명지
-- 최초 작성일 : 2020-01-20 13:01:58
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		$(document).ready(function() {
			createAUIGrid();
			var hideList = ["breg_rep_name", "tel_no", "construct_part", "lead_time", "delivery_rate", "estimation", "incoterms", "out_case", "this_year", "last_year", "past_year", "contract_mng_cd", "kuemhng_yn", "domuen_yn"];
			if('${inputParam.fieldType}' == 'wide') {
				window.resizeTo(1200, 585);
				AUIGrid.setColumnPropByDataField(auiGrid, "point_case", {"width" : "7%"} );
				AUIGrid.setColumnPropByDataField(auiGrid, "com_buy_group_name", {"width" : "18%"} );
				AUIGrid.setColumnPropByDataField(auiGrid, "cust_name", {"width" : "10%"} );
			} else {
				AUIGrid.hideColumnByDataField(auiGrid, hideList);
			}
			if ('${inputParam.s_cust_name}' != ''){
				goSearch();
			}

			// 부품마스터에서 매입처 조회시 그룹 A로 바로 조회되도록 추가 요청 (2021-01-12)
			if ('${inputParam.s_part_search_yn}' == 'Y'){
				$M.setValue("s_com_buy_group_cd", '${inputParam.s_com_buy_group_cd}');
				goSearch();
			}
		});
	
		//팝업 닫기
		function fnClose() {
			window.close(); 
		}
		
		function enter(fieldObj) {
			var field = ["s_com_buy_group_cd", "s_cust_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}
		
		function goSearch() {
			var param = {
					"s_sort_key" : "com_buy_group_cd asc",
					"s_sort_method" : "cust_name asc",
					"s_com_buy_group_cd" : $M.getValue("s_com_buy_group_cd"),
					"s_cust_name" : $M.getValue("s_cust_name"),
					"s_field_type" : "${inputParam.fieldType}" == "comm" ? "Y" : "N"
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
						$("#total_cnt").html(result.total_cnt);
					};
				}
			);
		}
		
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "row_id",
				rowStyleFunction : function(rowIndex, item) {
					/* if(item.estimation == "나쁨") {
						return "aui-color-red";
					}  */
				}
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    dataField: "breg_seq",
					visible : false
				},
				{
				    headerText: "그룹",
				    dataField: "com_buy_group_name",
					style : "aui-center"
				},
				{
					headerText : "업체명",
					dataField : "cust_name",
					style : "aui-left",
				},
				{
					headerText : "대표자",
					dataField : "breg_rep_name",
					style : "aui-center",
				},
				{
					headerText : "전화",
					dataField : "tel_no",
					width : "10%",
					style : "aui-center",
				},
				{
					headerText : "구성품목",
					dataField : "construct_part",
					style : "aui-center",
				},
				{
					headerText : "계약/LT",
					dataField : "lead_time",
					style : "aui-center",
				},
				{
					headerText : "납기율",
					dataField : "delivery_rate",
					style : "aui-center",
				},
				{
					headerText : "업체평가",
					dataField : "point_case",
					style : "aui-center",
					width: "15%"
					
				},
				{
					headerText : "INCOTERMS",
					dataField : "incoterms",
					style : "aui-center",
				},
				{
					headerText : "지불조건",
					dataField : "out_case",
					style : "aui-center",
				},
				{
					headerText : "당해매입",
					dataField : "this_year",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
				},
				{
					headerText : "전년매입",
					dataField : "last_year",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
				},
				{
					headerText : "전전년매입",
					dataField : "past_year",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
				},
				{
					headerText : "계약",
					dataField : "contract_mng_cd",
					style : "aui-center",
				},
				{
					headerText : "금형",
					dataField : "kuemhng_yn",
					style : "aui-center",
				},
				{
					headerText : "도면",
					dataField : "domuen_yn",
					style : "aui-center",
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
				}
			});
			$("#auiGrid").resize();
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
							<col width="50px">
							<col width="80px">
							<col width="30px">
							<col width="220px">
							<col width="10px">
						</colgroup>
						<tbody>
							<tr>
								<th>매입처명</th>
								<td>
									<input type="text" class="form-control" id="s_cust_name" name="s_cust_name" value="${inputParam.s_cust_name}">
								</td>
								<th>그룹</th>
								<td>
									<select class="form-control" style="width: 190px;" id="s_com_buy_group_cd" name="s_com_buy_group_cd">
										<option value="">- 전체 -</option>
										<c:forEach var="list" items="${codeMap['COM_BUY_GROUP']}">
												<option value="${list.code_value}">${list.code_desc}</option>
										</c:forEach>
									</select>
								</td>
								<td class=""><button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button></td>
							</tr>
						</tbody>
					</table>
				</div>
<!-- /검색영역 -->
				<div id="auiGrid" style="margin-top: 5px;height: 370px;"></div>
			</div>		
<!-- /폼테이블 -->
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