<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 거래현황 > 할인쿠폰관리 > 할인쿠폰신규등록 > null
-- 작성자 : 박준영
-- 최초 작성일 : 2020-09-21 17:08:26
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	

		$(document).ready(function () {
			fnInit();
		});
	
		//고객정보가 있으면 바로 세팅하기
		function fnInit() {
			
			if ("${cust_no}" != ""){				
				var custNo = "${cust_no}";
				getCustInfo(custNo);
				
			}

			var now = "${inputParam.s_current_dt}";
			$M.setValue("expire_plan_dt", $M.addYears($M.toDate(now),2));
			
			
		}
		
		function getCustInfo(custNo) {

			var param = {
					s_cust_no : custNo
			};
			$M.goNextPageAjax("/comp/comp0301/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						var list = result.list;
						switch(list.length) {
							case 0 :
								break;
							case 1 : 
								var row = list[0];
								fnSetCustInfo(row);
								break;
							default :
								break;
						}
					}
				}
			);
		}
		
		function fnSetBregInfo(data) {

			var param = {
   					breg_seq : data.breg_seq,
   					breg_name : data.breg_name,
   					breg_no : data.breg_no,
   					breg_rep_name : data.breg_rep_name,
   					breg_cor_type : data.breg_cor_type,
   					breg_cor_part : data.breg_cor_part,
   					biz_post_no : data.biz_post_no,
   					biz_addr1 : data.biz_addr1,
   					biz_addr2 : data.biz_addr2

   				}
   				console.log(" ---> ", param);
   				$M.setValue(param);	
		}
	
		function fnSetCustInfo(data) {
			console.log("data : ", data);
			//고객조회 - 사업자인경우 사업자 주소도 가져오기
				
			if ( data.breg_no == ""){					
				alert("사업자 정보가 없습니다.");
			}
				
   			var param = {
   					cust_no : data.cust_no,
   					cust_name : data.real_cust_name,
   					deposit_name : data.deposit_name,
   					cust_hp_no : $M.phoneFormat(data.real_hp_no),
   					sum_balance_amt : data.sum_balance_amt,
   					breg_seq : data.breg_seq,
   					breg_name : data.breg_name,
   					breg_no : data.breg_no,
   					sale_mem_name : data.sale_mem_name,
   					breg_rep_name : data.breg_rep_name,
   					breg_cor_type : data.breg_cor_type,
   					breg_cor_part : data.breg_cor_part,
   					biz_post_no : data.biz_post_no,
   					biz_addr1 : data.biz_addr1,
   					biz_addr2 : data.biz_addr2,
   				}
   				console.log(" ---> ", param);
   				$M.setValue(param);	
		}		
		    
	 	// 문자발송
		function fnSendSms() {
			var param = {
					  name : $M.getValue("cust_name"),
					  hp_no : $M.getValue("cust_hp_no")
			  }
			openSendSmsPanel($M.toGetParam(param));
		}
	    	 	
	    // 입금자명 변경
	    function goChangeDeposit() {
	    	$("#btnChange").children().eq(0).attr("id", "btnDeposit");
			if($("#btnDeposit").text() == "입금자명변경") {
				$("#deposit_name").prop("readonly", false);
				$("#deposit_name").off("keydown");
				$("#btnDeposit").text("정정");
			} else if($("#btnDeposit").text() == "정정") {
				var params = {
					"cust_no" : $M.getValue("cust_no"),
					"deposit_name" : $M.getValue("deposit_name")
				};

				$M.goNextPageAjax(this_page + "/changeDeposit", $M.toGetParam(params), {method : "POST"},
					function(result) {
						if(result.success) {
							$("#btnDeposit").text("입금자명변경");
							$("#deposit_name").prop("readonly", true);
						}
					}
				);
			}
	    }
	 
	    // 저장
	    function goSave() {
			
	    	var frm = document.main_form;

	    	if ($M.validation(frm) == false) {
				return;
			};
				
			if ($M.getValue("expire_plan_dt") <= "${inputParam.s_current_dt}" ){
				alert("소멸예정일은 오늘이후날짜만 지정 가능합니다.");
				return;
			}
			
			if ($M.getValue("expire_plan_dt") <= $M.getValue("inout_dt") ){
				alert("소멸예정일은 전표날짜 이후로만 지정 가능합니다.");
				return;
			}
			
			$M.goNextPageAjaxSave(this_page + "/save", $M.toValueForm(frm), { method : "POST"},
					function(result) {
						if(result.success) {
							
							alert(result.result_msg);
							// 창닫기
							window.close();
						};
					}
				);						
	    }
	    
		function fnClose() {
			window.close();
		}
	 
	</script>
</head>
<body  class="bg-white">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
    <div class="main-title">
    	<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
    </div>
<!-- /타이틀영역 -->
<!-- contents 전체 영역 -->
		<div class="content-wrap" >
<!-- 폼테이블 -->	
			<div>
				<table class="table-border">
					<colgroup>
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">전표번호</th>
							<td>										
								<input type="text" class="form-control width120px" id="inout_doc_no" name="inout_doc_no" value=""  readonly="readonly">
							</td>
							<th class="text-right essential-item">전표일자</th>
							<td>
								<div class="input-group width120px">
									<input type="text" class="form-control border-right-0 calDate rb" id="inout_dt" name="inout_dt"   required="required" dateformat="yyyy-MM-dd" alt="전표일자" value="${inputParam.s_current_dt}">
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">고객명</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0 width100px" id="cust_name" name="cust_name" required="required" alt="고객명" value=""   readonly="readonly">
									<input type="hidden" id="cust_no" 	name="cust_no" 	value=""  >
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchCustPanel('fnSetCustInfo');"><i class="material-iconssearch"></i></button>
								</div>
							</td>
							<th class="text-right essential-item">연락처</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0 width100px" id="cust_hp_no" name="cust_hp_no"  required="required" alt="연락처" value=""   readonly="readonly" >
									<button type="button" class="btn btn-icon btn-primary-gra"  onclick="javascript:fnSendSms();"><i class="material-iconsforum"></i></button>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">담당자</th>
							<td>
								<input type="text" class="form-control width120px" id="sale_mem_name" name="sale_mem_name" value=""   readonly="readonly">
							</td>
							<th class="text-right essential-item">처리자</th>
							<td>
								<input type="text" class="form-control width120px" id="kor_name" name="kor_name"  value="${SecureUser.kor_name}"   readonly="readonly">
								<input type="hidden" id="mem_no" 	name="mem_no" 	value="${SecureUser.mem_no}"  >
							</td>
						</tr>
						<tr>
							<th class="text-right">업체명</th>
							<td>
								<input type="text" class="form-control width120px" id="breg_name" name="breg_name" value=""   readonly="readonly">
							</td>
							<th class="text-right">대표자</th>
							<td>
								<input type="text" class="form-control width120px" id="breg_rep_name" 	name="breg_rep_name" value=""    readonly="readonly">
							</td>
						</tr>
						<tr>
							<th class="text-right">사업자No</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width160px">
										<input type="text" class="form-control" id="breg_no" 	name="breg_no" value=""   readonly="readonly">
									</div>
									<div class="col width60px">
										<button type="button" class="btn btn-primary-gra" onclick="javasctipt:openSearchBregInfoPanel('fnSetBregInfo');">변경</button>
									</div>
								</div>										
							</td>
							<th class="text-right">입금자</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width120px">
										<input type="text" class="form-control" id="deposit_name" name="deposit_name" value=""  readonly="readonly">
									</div>
									<div class="col-auto" id="btnChange">
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_M"/></jsp:include>
									</div>

								</div>	
							</td>
						</tr>
						<tr>
							<th class="text-right">주소</th>
							<td colspan="3">
								<div class="form-row inline-pd mb7 widthfix">
									<div class="col-3">
										<input type="text" class="form-control" id="biz_post_no" name="biz_post_no" value=""  readonly="readonly">
									</div>
									<div class="col-9">
										<input type="text" class="form-control" id="biz_addr1" name="biz_addr1" value=""  readonly="readonly">
									</div>
								</div>
								<div class="form-row inline-pd">
									<div class="col-12">
										<input type="text" class="form-control" id="biz_addr2" name="biz_addr2" value=""  readonly="readonly" >
									</div>
								</div>
							</td>
						</tr>	
						<tr>
							<th class="text-right essential-item">쿠폰금액</th>
							<td  colspan="3">
								<div class="form-row inline-pd widthfix">
									<div class="col width120px">
										<input type="text" class="form-control text-right" id="coupon_amt" name="coupon_amt"  value=""  required="required" alt="쿠폰금액" datatype="int" format="decimal"  min="10" >
									</div>
									<div class="col width16px">원</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">소멸예정일</th>
							<td>
								<div class="input-group width120px">
									<input type="text" class="form-control border-right-0 calDate rb" id="expire_plan_dt" name="expire_plan_dt" dateformat="yyyy-MM-dd"  required="required" alt="소멸예정일" value="">
								</div>
							</td>
							<th class="text-right">쿠폰 현 잔액</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width120px">
										<input type="text" class="form-control text-right" id="sum_balance_amt" name="sum_balance_amt" value=""  datatype="int" format="decimal"  readonly="readonly">
									</div>
									<div class="col width16px">원</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">최종메모</th>
							<td colspan="3">
								<textarea class="form-control" readonly="readonly" value=""  style="height: 50px;"></textarea>
							</td>
						</tr>
						<tr>
							<th class="text-right">비고</th>
							<td colspan="3">
								<textarea class="form-control" id="remark" name="remark" value=""  style="height: 50px;"></textarea>
							</td>
						</tr>
						<tr>
							<th class="text-right">적요</th>
							<td colspan="3">
								<textarea class="form-control" id="desc_text" name="desc_text" value=""  style="height: 50px;"></textarea>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
<!-- /폼테이블 -->	
<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">						
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
			</div>		
<!-- /contents 전체 영역 -->	
    </div>
<!-- /팝업 -->
</form>	
</body>
</html>