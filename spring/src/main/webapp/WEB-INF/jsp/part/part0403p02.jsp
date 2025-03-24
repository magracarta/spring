<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 발주/납기관리 > 부품발주관리 > null > 매출이력
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-01-10 17:06:42
-- inout_doc_type (asis paperid)에 따른 정비지시서항목 상세링크는 acnt0301p03을 참고했음. 
-- asis 매출이력 jsp 주소 :  parts030304SaleHistory
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		<%-- 여기에 스크립트 넣어주세요. --%>
		
		var auiGrid;
		
		$(document).ready(function() {
			createAUIGrid(); // 메인 그리드
		});
		
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
				s_part_no : $M.getValue("part_no"),
				s_sort_key : "inout_dt",
				s_sort_method : "desc"
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						console.log(result.list);
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}
		
		function fnClose() {
			window.close();
		}
		
		function createAUIGrid() {
			var gridPros = {
					height : "250px"
			};
			var columnLayout = [
				{
					dataField : "_$uid", 
					visible : false
				},
				{
					dataField : "inout_dt",
					headerText : "처리일자", 
					dataType : "date", 
					dataInputString : "yyyymmdd",
					formatString : "yyyy-mm-dd"
				},
				{
					dataField : "inout_doc_no",
					style : "aui-popup",
					headerText : "전표번호", 
				},
				{
					dataField : "cust_name",
					headerText : "고객명", 
				},
				{
					dataField : "breg_name",
					headerText : "업체명", 
				},
				{
					dataField : "qty",
					headerText : "매출수량", 
				},
				{
					dataField : "inout_org_name",
					headerText : "처리창고", 
				},
				// 2021.07.15 (SR:11355) 모델명 추가요청 - 황빛찬
				{
					dataField : "machine_name",
					headerText : "모델", 
				},
				{
					dataField : "inout_doc_type_cd",
					visible : false
				},
				{
					dataField : "inout_type_cd",
					visible : false
				},
				{
					dataField : "cust_coupon_no",
					visible : false
				},
				{
					dataField : "cust_no",
					visible : false
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "inout_doc_no") {
					var inoutDocTypeCd = event.item["inout_doc_type_cd"]; // asis paperid
					var inoutTypeCd = event.item["inout_type_cd"]; // asis inoutid
					var popupOption = "";
					var param = {};
					if (inoutDocTypeCd == "00") { // 기타전표
						// asis
						// OpenWindowScroll('/parts/parts030303EtcForm.do',"605","605", "기타전표", {customerid : customerid});
						param.inout_doc_no = event.item["inout_doc_no"];
						$M.goNextPage("/cust/cust0203p01", $M.toGetParam(param), {popupStatus : popupOption}); // 입출금전표처리 상세
						
					} else if (inoutDocTypeCd == "02" || inoutDocTypeCd == "10") { // 발주서참조, 옵션부품입고
						$M.goNextPage("/part/part0302p01", $M.toGetParam(param), {popupStatus : popupOption});		// 매입처리 상세
						
					} else if (inoutDocTypeCd == "04" || inoutDocTypeCd == "05") { // 수주참조, 주문서참조
						param.inout_doc_no = event.item["inout_doc_no"];
						$M.goNextPage("/cust/cust0202p01", $M.toGetParam(param), {popupStatus : popupOption});		// 매출처리 상세
						
					} else if (inoutDocTypeCd == "06") { // 쿠폰전표
						if (inoutTypeCd == "01") {
							param.inout_doc_no = event.item["inout_doc_no"];
							$M.goNextPage("/cust/cust0203p01", $M.toGetParam(param), {popupStatus : popupOption});		// 입출금전표처리 상세
						} else { // 쿠폰처리
							param.cust_coupon_no = event.item["cust_coupon_no"];
							$M.goNextPage("/cust/cust0305p01", $M.toGetParam(param), {popupStatus : popupOption});	// 쿠폰처리 상세
						}
					} else if (inoutDocTypeCd == "07") { // 정비지시서 참조
						// acnt0301p03 정비지시서 코맨트 참고
						/* if (inoutTypeCd == "01") {
							
						} else {
							
						} */
						param.inout_doc_no = event.item["inout_doc_no"];
						$M.goNextPage("/cust/cust0202p01", $M.toGetParam(param), {popupStatus : popupOption});		// 매출처리 상세
						
					} else if (inoutDocTypeCd == "08") { // 출하의뢰서
						param.machine_doc_no = event.item["machine_doc_no"];
						$M.goNextPage("/sale/sale0101p03", $M.toGetParam(param), {popupStatus : popupOption});	// 출하의뢰서
						
						
					//} else if (inoutDocTypeCd == "99") { // 창고이동(미추가), 안쓰는듯
						
					} else if (inoutDocTypeCd == "09") { // ARS 결재
						param.cust_no = event.item["cust_no"];
						$M.goNextPage("/comp/comp0703", $M.toGetParam(param), {popupStatus : popupOption});		//  ARS 결제
					}
				} 
			});
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.resize(auiGrid);
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" name="part_no" id="part_no" value="${item.part_no }">
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
						<h4>${item.part_no }</h4>					
						<div class="com-info">${item.part_name }</div>
					</div>
				</div>						
<!-- 검색영역 -->					
				<div class="search-wrap mt5">
					<table class="table">
						<colgroup>
							<col width="65px">
							<col width="240px">
							<col width="">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th class="rs">조회일자</th>
								<td>
									<div class="form-row">
										<div class="col width110px">
											<div class="input-group">
												<input type="text" class="form-control rb border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="요청시작일" required="required" value="${inputParam.s_start_dt }">
											</div>
										</div>
										<div class="col-auto" style="padding: 0">~</div>
										<div class="col width120px">
											<div class="input-group">
												<input type="text" class="form-control rb border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="요청종료일" required="required" value="${inputParam.s_end_dt }">
											</div>
										</div>
									</div>
								</td>
								<td class=""><button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()">조회</button></td>
								<td class="text-right text-warning">※ 정비지시서 매출의 경우 해당 모델이, 수주매출의 경우 보유기종이 목록에 표시됩니다.</td>
							</tr>
						</tbody>
					</table>
				</div>
<!-- /검색영역 -->
				<div id="auiGrid" style="margin-top: 5px; height: 250px;"></div>
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