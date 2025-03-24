<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 거래현황 > 계좌입출금내역 > null > 가상계좌
-- 작성자 : 박예진
-- 최초 작성일 : 2020-04-28 09:08:26
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
			goSearch();
		});
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
					rowIdField : "virtual_account_no",
					showStateColumn : false,
					// No. 제거
					showRowNumColumn: true,
					editable : false
				};
			var columnLayout = [
				{
					headerText : "가상계좌번호", 
					dataField : "virtual_account_no", 
					style : "aui-center"
				},
				{ 
					headerText : "지점고객명", 
					dataField : "cust_name", 
					width : "23%",
					style : "aui-center"
				},
				{ 
					headerText : "연락처", 
					dataField : "hp_no", 
					width : "20%",
					style : "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					     if(String(value).length > 0) {
					         // 전화번호에 대시 붙이는 정규식으로 표현
					         return value.replace(/(^02.{0}|^01.{1}|[0-9]{3})([0-9]+)([0-9]{4})/,"$1-$2-$3"); 
					     }
					     return value; 
					}
				},
				{
					headerText : "한도액",
					dataField : "in_max_amt",
					// width : "20%",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
				},
				{ 
					headerText : "입금액", 
					dataField : "in_amt",
					// width : "20%",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
				},
				{ 
					headerText : "상태", 
					dataField : "status", 
					width : "12%",
					style : "aui-center",
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
		}
		
		function goSearch() {
			var param = {
					"s_assign_ynd" : $M.getValue("s_assign_ynd")
			};
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
							$("#total_cnt").html(result.total_cnt);
						};
					}
				);
		}
	
		function fnClose() {
			window.close();
		}

		// 가상계좌 등록 팝업
		function goVirtualAccountAddPopup() {
			var params = {
                "parent_js_name" : "goSearch"
            };
			var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=100, height=100, left=0, top=0";
			$M.goNextPage('/cust/cust0303p03', $M.toGetParam(params), {popupStatus : popupOption});
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
<!-- 처리내역 -->
			<div>
				<div class="title-wrap">
					<div class="left">
						<h4>가상계좌발급내역</h4>	
					</div>
					<div class="right">
						<div class="form-check form-check-inline">
							<input class="form-check-input" type="radio" id="s_assign_ynd_y" name="s_assign_ynd" value="Y" onChange="goSearch();" checked="checked">
							<label class="form-check-label">사용중</label>
						</div>
						<div class="form-check form-check-inline">
							<input class="form-check-input" type="radio" id="s_assign_ynd_n" name="s_assign_ynd" value="N" onChange="goSearch();">
							<label class="form-check-label">미지정</label>
						</div>
						<div class="form-check form-check-inline">
							<input class="form-check-input" type="radio" id="s_assign_ynd_d" name="s_assign_ynd" value="D" onChange="goSearch();">
							<label class="form-check-label">완료</label>
						</div>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 200px;"></div>

			</div>
<!-- /처리내역 -->
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