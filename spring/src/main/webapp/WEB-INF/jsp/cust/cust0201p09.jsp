<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 부품판매 > 수주현황/등록 > null > 배송추적
-- 작성자 : 정윤수
-- 최초 작성일 : 2023-08-28 10:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
		});
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				editable : false,
				showRowNumColumn: false,
			};
			var columnLayout = [
				{ 
					headerText : "구분", 
					dataField : "send_agency",
					width : "120",
					style : "aui-center",
				},
				{ 
					headerText : "취급점명", 
					dataField : "send_agency_name",
					width : "120",
					style : "aui-center",
				},
				{
					headerText : "전화번호",
					dataField : "send_agency_tel",
					width : "120",
					style : "aui-center",
				},
				{ 
					headerText : "도착(접수)일시", 
					dataField : "arrival_date",
					width : "120",
					style : "aui-center",
				},
				{ 
					headerText : "출발(배달)일시", 
					dataField : "send_date",
					width : "120",
					style : "aui-center",
				},
				{ 
					headerText : "현재위치", 
					dataField : "trace_state",
					width : "120",
					style : "aui-center",
				},
				
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});
			$("#auiGrid").resize();
		}
		
		   
		// 닫기
		function fnClose() {
			window.close();
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
			<div class="search-wrap">
				<h3 class="text-center"  style="font-weight: bold; font-size: 13px;">운송장 번호 : ${map.bill_no}</h3>
			</div>
<!-- 상단 폼테이블 -->					
			<div>
				<div class="text-right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
				</div>
				<div class="title-wrap">
					<h4>기본정보</h4>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="150px">
						<col width="">
						<col width="150px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">보내신 분</th>
							<td>
								<div class="">
									<input type="text" class="form-control width120px" id="send_name" name="send_name" readonly="readonly" value="${map.send_name}">
								</div>
							</td>	
							<th class="text-right">전화번호</th>
							<td>
								<input type="text" class="form-control width120px" id="send_tel_no" name="send_tel_no" readonly="readonly" value="${map.sending_man_tel}">
							</td>													
						</tr>
						<tr>
							<th class="text-right">받으실 분</th>
							<td>
								<input type="text" class="form-control width120px" id="arrive_man" name="arrive_man" readonly="readonly" value="${map.arrive_man}">
							</td>
							<th class="text-right">전화번호</th>
							<td>
								<input type="text" class="form-control width120px" id="arrive_man_tel" name="arrive_man_tel" readonly="readonly" value="${map.arrive_man_tel}">
							</td>									
						</tr>
						<tr>
							<th class="text-right">품명</th>
							<td>
								<input type="text" class="form-control width120px" id="goods" name="goods" alt="수량" format="decimal" readonly="readonly" value="${map.goods}">
							</td>
							<th class="text-right">수량</th>
							<td>
								<input type="text" class="form-control width120px" id="qty" name="qty" value="${map.qty}" readonly="readonly">
							</td>									
						</tr>
						</tr>			
					</tbody>
				</table>
			</div>
<!-- /상단 폼테이블 -->	
<!-- 그리드 타이틀, 컨트롤 영역 -->
			<div class="title-wrap mt10">
				<h4>배송추적상태</h4>
			</div>
			<div id="auiGrid" style="margin-top: 5px; height: 380px;"></div>
<!-- /그리드 타이틀, 컨트롤 영역 -->
			<c:if test="${map.invoice_result ne ''}">
				<div class="search-wrap mt10">
					<h3 class="text-center "  style="font-weight: bold; font-size: 13px; ">${map.invoice_result}</h3>
				</div>
			</c:if>
			
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>