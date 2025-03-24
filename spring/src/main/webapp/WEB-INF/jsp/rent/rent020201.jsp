<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈대장 > 어태치먼트대장 > 어태치먼트 신규등록 > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
		// 기타매입처일 경우 비고 필수입력, 추후 cust_no 변경
		var etcClient = "20200722000000001";
		
		// 매입처
		function fnSetClient(row) {
			var param = {
				client_cust_name : row.cust_name,
			}
			$M.setValue(param);
		}
		
		function fnCalc() {
			// 운영월수 = 매입일자부터 오늘까지 개월 수(소수첫째짜리까지 표현)
			var todayDt = "${inputParam.s_current_dt}";
			var buyDt = $M.getValue("buy_dt");
			var diff = $M.getDiff(todayDt, buyDt, {isEqualZero: true});
			console.log("운영일수 : ", diff);
			// var opMonth = Math.round((diff/30)*10)/10;
			var opMonth = diff/30;
			console.log("운영월수 : ", opMonth);
			
			/* var strtYear = parseInt(buyDt.substring(0,4));
			var strtMonth = parseInt(buyDt.substring(4,6));

			var endYear = parseInt(todayDt.substring(0,4));
			var endMonth = parseInt(todayDt.substring(4,6));

			var month = (endYear - strtYear)* 12 + (endMonth - strtMonth);
			console.log(month); */
			
			// 매입가
			var buyPrice = $M.toNum($M.getValue("buy_price"));
			console.log("매입가 : ", buyPrice);
			
			// 이자율
			var rate =  $M.toNum($M.getValue("interest_rate"));
			console.log("이자율 : ", rate);
			
			// 이자금액 = 매입가 * (이자율*운영월수/12)
			// var interest = Math.round((buyPrice*((rate*100/100)*opMonth/12))*100/100);
			var interest = buyPrice*((rate*100/100)*opMonth/12);
			console.log("이자금액 : ", interest);
			
			// 어태치 가액 = 매입가 + 이자금액
			var attach = buyPrice+interest;
			
			// 수리비용
			var repair = 0;
			
			// 최종 어태치 가액(구명칭 : 최종가액) = 어태치가액 + 수리비용
			var finalAttach = attach + repair;
			
			// 월감가액
			var reducePrice = $M.toNum($M.getValue("reduce_price"));
			
			// 감가총액 = 월감가액 * 운영월수
			var totalDepreciation = reducePrice * opMonth;
			
			// 최소판가 = 최종가액 + 수리비용 - 감가총액 
			var minSalePrice = finalAttach + 0 - 0;
			
			var param = {
				op_month : opMonth
				, interest_amt : interest
				, repair : repair
				, final_attach : finalAttach
				, total_depreciation : totalDepreciation
				, min_sale_price : minSalePrice
			}
			
			$M.setValue(param);
			
		}
		
		function goAttachPopup() {
			param = {
				"parent_js_name" : "fnSetAttach"
			};	
			var poppupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=570, height=725, left=0, top=0";
			$M.goNextPage('/rent/rent0202p02', $M.toGetParam(param), {popupStatus : poppupOption});
		}
		
		function fnSetAttach(row) {
			var param = {
				 part_no : row.part_no
				, attach_name : row.attach_name
				, part_name : row.part_name
				, buy_price : row.buy_price
				, interest_rate : row.interest_rate
				, part_no_machine : row.part_no_machine
				, cost_yn : row.cost_yn
			};
			$M.setValue(param);
			fnCalc();
		}
		
		function fnList() {
	    	$M.goNextPage("/rent/rent0202");
	    }
		
		function goSave() {
			var frm = document.main_form;
			if($M.validation(frm) == false) {
				return;
			};
			if($M.checkRangeByFieldName("reduce_st_dt", "reduce_ed_dt", true) == false) {				
				return;
			}; 
			$M.goNextPageAjaxSave(this_page, $M.toValueForm(frm), {method : 'POST'},
					function(result) {
			    		if(result.success) {
			    			alert("저장이 완료되었습니다.");
			    			fnList();
						}
					}
				);
		}
	
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="interest_rate" name="interest_rate"> 
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 상세페이지 타이틀 -->
				<div class="main-title detail">
					<div class="detail-left">
						<button type="button" class="btn btn-outline-light" onclick="javascript:fnList()"><i class="material-iconskeyboard_backspace text-default"></i></button>
						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
					</div>
				</div>
<!-- /상세페이지 타이틀 -->
				<div class="contents">
<!-- 폼 테이블 -->			
					<table class="table-border">
						<colgroup>
							<col width="100px">
							<col width="">
							<col width="100px">
							<col width="">
							<col width="100px">
							<col width="">
							<col width="100px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right">관리번호</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width120px">
											<input type="text" class="form-control" readonly="readonly">
										</div>
										<!-- 어태치관리번호 2개에서 하나로 합쳐서 보여줌 by 부장님 지시 -->
										<!-- <div class="col width70px">
											<input type="text" class="form-control" readonly="readonly">
										</div>
										<div class="col width16px text-center">-</div>
										<div class="col width50px">
											<input type="text" class="form-control" readonly="readonly">
										</div> -->
									</div>
								</td>
								<th class="text-right rs">매입일자</th>
								<td>
									<div class="input-group width100px">
										<input type="text" class="form-control border-right-0 calDate rb" id="buy_dt" name="buy_dt" dateFormat="yyyy-MM-dd" value="${inputParam.s_current_dt}" alt="매입일자" required="required" onchange="javascript:fnCalc()">
									</div>
								</td>
								<th class="text-right rs">소유센터</th>
								<td>
									<select class="form-control rb width100px" id="own_org_code" name="own_org_code" required="required" alt="소유센터">
										<option value="">- 선택 -</option>
										<c:forEach var="item" items="${orgCenterList}">
											<option value="${item.org_code}">${item.org_name}</option>
										</c:forEach>
									</select>
								</td>
								<th class="text-right">유/무상여부</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" checked="checked" value="Y" name="cost_yn" id="cost_yn_y" disabled>
										<label class="form-check-label" for="cost_yn_y">유상</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" value="N" name="cost_yn" id="cost_yn_n" disabled>
										<label class="form-check-label" for="cost_yn_n">무상</label>
									</div>									
								</td>								
							</tr>
							<tr>
								<th class="text-right">매입처</th>
								<td>
									<div class="input-group">
										<input type="text" class="form-control border-right-0" id="client_cust_name" name="client_cust_name">
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchClientPanel('fnSetClient');" ><i class="material-iconssearch"></i></button>
									</div>
								</td>
								<th class="text-right rs">어태치 매입가</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control rb text-right" id="buy_price" name="buy_price" alt="매입가" required="required" onchange="javascript:fnCalc()" format="decimal">
										</div>
										<div class="col width16px">원</div>
									</div>
								</td>
								<th class="text-right rs">관리센터</th>
								<td>
									<select class="form-control rb width100px" id="mng_org_code" name="mng_org_code" alt="관리센터" required="required">
										<option value="">- 선택 -</option>
										<c:forEach var="item" items="${orgCenterList}">
											<option value="${item.org_code}">${item.org_name}</option>
										</c:forEach>
									</select>
								</td>
								<th class="text-right">렌탈매출</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly="readonly" value="0">
										</div>
										<div class="col width16px">원</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right rs">어태치먼트명</th>
								<td>
									<div class="input-group">
										<input type="text" class="form-control border-right-0" readonly="readonly" id="attach_name" name="attach_name" alt="어태치먼트명" required="required">
										<input type="hidden" id="part_no" name="part_no">
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goAttachPopup();" ><i class="material-iconssearch"></i></button>
									</div>
								</td>
								<th class="text-right">이자금액</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly="readonly" id="interest_amt" name="interest_amt" format="decimal">
										</div>
										<div class="col width16px">원</div>
									</div>
								</td>
								<th class="text-right">감가여부</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" value="Y" name="reduce_yn" id="reduce_yn_y">
										<label class="form-check-label" for="reduce_yn_y">적용</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" value="N" name="reduce_yn" id="reduce_yn_n" checked="checked">
										<label class="form-check-label" for="reduce_yn_n">미적용</label>
									</div>
								</td>
								<th class="text-right">월감가액</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" id="reduce_price" name="reduce_price" onchange="javascript:fnCalc()" format="decimal">
										</div>
										<div class="col width16px">원</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">부품번호</th>
								<td>
									<input type="text" class="form-control" id="part_no_machine" name="part_no_machine" alt="모델명" readonly="readonly">
									<input type="hidden" class="form-control" id="part_no" name="part_no" alt="모델명" readonly="readonly">
								</td>
								<th class="text-right">수리금액</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly="readonly" id="repair" name="repair" format="decimal">
										</div>
										<div class="col width16px">원</div>
									</div>
								</td>
								<th class="text-right">감가시작일</th>
								<td>
									<div class="input-group width100px">
										<input type="text" class="form-control border-right-0 calDate" id="reduce_st_dt" name="reduce_st_dt" dateFormat="yyyy-MM-dd" value="${inputParam.s_current_dt}"  alt="감가시작일">
									</div>
								</td>
								<th class="text-right">감가총액</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly="readonly" id="total_depreciation" name="total_depreciation" format="decimal">
										</div>
										<div class="col width16px">원</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">일련번호</th>
								<td>
									<input type="text" class="form-control" id="product_no" name="product_no" >
								</td>
								<th class="text-right">최종 어태치가액</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly="readonly" id="final_attach" name="final_attach" format="decimal">
										</div>
										<div class="col width16px">원</div>
									</div>
								</td>
								<th class="text-right">감가종료일</th>
								<td>
									<div class="input-group width100px">
										<input type="text" class="form-control border-right-0 calDate" id="reduce_ed_dt" name="reduce_ed_dt" dateFormat="yyyy-MM-dd" value="" alt="감가 종료일">
									</div>
								</td>
								<th class="text-right">최소판가</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly="readonly" id="min_sale_price" name="min_sale_price" format="decimal">
										</div>
										<div class="col width16px">원</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right r1s">비고</th>
								<td>
									<input type="text" class="form-control r1b"  id="remark" name="remark" >
								</td>
								<th class="text-right">운영월수</th>
								<td colspan="5">
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly="readonly" id="op_month" name="op_month" format="decimal">
										</div>
									</div>
								</td>
							</tr>								
						</tbody>
					</table>			
<!-- /폼 테이블 -->	
					<div class="btn-group mt10">
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