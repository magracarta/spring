<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 정산 > 중고장비관리 > null > 중고장비상세
-- 작성자 : 박준영
-- 최초 작성일 : 2020-06-12 16:40:14
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">


		$(document).ready(function() {
							
			// AUIGrid 생성
			createAUIGrid();			
			$M.setValue("__s_machine_seq", $M.getValue("machine_seq"));	
			$M.setValue("__s_machine_doc_no", $M.getValue("machine_doc_no"));
			fnCalcAmt();	//첫로딩시 손익을 계산
		});
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				// No. 제거
				showRowNumColumn: true,
				editable : false,
				showFooter : true,
				footerPosition : "top",
				enableMovingColumn : false
			};
			var columnLayout = [
				{
					headerText : "처리일자", 
					dataField : "proc_dt", 
					dataType : "date",  
					formatString : "yyyy-mm-dd",
					width : "10%",
					style : "aui-center"
				},
				{ 
					headerText : "내역", 
					dataField : "desc_text", 
					width : "25%",
					style : "aui-left"
				},
				{ 
					headerText : "매출", 
					dataField : "sale_amt", 
					formatString : "#,##0",
					dataType : "numeric",
					width : "10%",
					style : "aui-right"
				},
				{ 
					headerText : "입금", 
					dataField : "deposit_amt", 
					formatString : "#,##0",
					dataType : "numeric",
					width : "10%",
					style : "aui-right"
				},
				{ 
					headerText : "잔액", 
					dataField : "balance_amt", 
					formatString : "#,##0",
					dataType : "numeric",
					width : "10%",
					style : "aui-right"
				},
				{ 
					headerText : "비고", 
					dataField : "remark", 
					style : "aui-left"
				}
			];
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "proc_dt",
					colSpan : 2,
					style : "aui-center aui-footer",
				}, 
				{
					dataField : "sale_amt",
					positionField : "sale_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				}, 
				{
					dataField : "deposit_amt",
					positionField : "deposit_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "balance_amt",
					positionField : "balance_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",	
					labelFunction : function(value, columnValues, footerValues) {
					   //잔액합 = 매출합 - 입금합
					   var balanceAmt = footerValues[1]-footerValues[2];
					   // 로직 처리
					   return balanceAmt;
					}
				}
			];
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
					
			var detailList = ${detailList};
			var balanceAmt = 0;
			for (var i = 0; i < detailList.length; ++i) {
				
				if (detailList[i].seq == "0") {
					balanceAmt =  $M.toNum(detailList[i].sale_amt);
				}		
				if (detailList[i].seq == "1") {
					balanceAmt = balanceAmt + $M.toNum(detailList[i].sale_amt) - $M.toNum(detailList[i].deposit_amt);
					detailList[i].balance_amt = balanceAmt;
				}
				
			}
			
			AUIGrid.setGridData(auiGrid, detailList);
			$("#auiGrid").resize();
		}
		
		// 문자발송
		function fnSendSms() {
			
			var param = {
					  name : $M.getValue("old_cust_name"),
					  hp_no : $M.getValue("hp_no")
			  }
			openSendSmsPanel($M.toGetParam(param));
			
		}

		// 기본 조직도 조회
		function setOrgMapPanel(result) {
			$M.setValue("sale_mem_no",result.mem_no);
			$M.setValue("sale_mem_name",result.mem_name);
			$M.setValue("sale_org_code",result.org_code);
		}
	    
		// 공급받는자 조회
		function goCustInfoClick() {

			var param = {};
			openSearchCustPanel('fnSetCustInfo', $M.toGetParam(param));
		}
		
		function fnSetCustInfo(data) {
			//console.log("data : ", data);
			$M.setValue("recipient_cust_name",data.real_cust_name );
			$M.setValue("recipient_cust_no",data.cust_no);
		}
		
		// 손익 계산
		function fnCalcAmt() {
			var contractPrice = $M.toNum($M.getValue("contract_price"));						//실판매가
			var usedPrice = $M.toNum($M.getValue("used_price"));								//매입가

			var usedLossAmt = 0;

				//손익 = 실판매가 - 매입가
				usedLossAmt = contractPrice - usedPrice;
		
			
			$M.setValue("used_loss_amt", usedLossAmt);
		}
		
	    function goSave(){

			var frm = document.main_form;
			
		  	// validation check
	     	if($M.validation(frm) === false) {
	     		return;
	     	};

	     	//매출등록전에만 사용 ( 매출등록후에는 비활성화 )
			$M.goNextPageAjaxSave(this_page + "/save", $M.toValueForm(frm), {method : 'POST'},
				function (result) {				
					if(result.success){
						alert("저장이 완료되었습니다.");
					}
					else {
						alert("처리에 오류가 발생하였습니다.");
					}
				}
				
			);
	    }
	    
	    // 매출세금계산서 처리 팝업
	    function goSale() {
	    	
	    	var frm = document.main_form;
	    	
	    	// validation check ( 기본 )
	    	if($M.validation(frm) === false) {
	     		return;
	     	};
	    	
	    	
	     	// validation check ( 매출세금계산서 처리 할때만 체크)
 			if($M.validation(frm, {field:["taxbill_dt","sale_dt","agent_price","contract_price","recipient_cust_name", "recipient_cust_no","sale_mem_name","old_cust_no"]}) == false) {
				return;
			};
	    	
			
			var contractPrice = $M.toNum($M.getValue("contract_price"));						//실판매가

			if(contractPrice<=0){
				alert("실판매가는 0보다 커야합니다.");
				return;
			}
			

	     	var msg="매출세금계산서를 등록하시겠습니까?"
	    	if(confirm(msg)) {
	    		
	    	  	//매출세금계산서 등록 전 저장
				$M.goNextPageAjax(this_page + "/save", $M.toValueForm(frm), {method : 'POST'},
					function (result) {
						if(result.success){					
							var param = {
									"machine_used_no" : $M.getValue("machine_used_no") 
							};					
				    		openInoutProcPanel("fnSetInout", $M.toGetParam(param));
						}
						else {
							alert("처리에 오류가 발생하였습니다.");
						}					
					}
				);
	    	}		
	    }
	    
	    
	   function fnSetInout() {
		   location.reload();
	   }
	    

	    //입금처리
	    function goInoutPopup() {
	    	
	    	var msg="입금처리 하시겠습니까?"
	    			
	    	if(confirm(msg)) {
		    	var popupOption = "";
	    		// 입출금전표처리
	    		var param = {
	    				"cust_no" : $M.getValue("recipient_cust_no"),
	    				"machine_used_no" : $M.getValue("machine_used_no"), 
	    				"popup_yn" : "Y"
	    		};
	    		
				$M.goNextPage('/cust/cust020301', $M.toGetParam(param), {popupStatus : popupOption});
	    	}

	    }

		// 닫기
		function fnClose() {
			window.close();
		}
		
		// 매출상세
		function goCompleteApproval() {
			var params = {
						"inout_doc_no" : $M.getValue("inout_doc_no")
			};
			var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=780, left=0, top=0";
			$M.goNextPage('/cust/cust0202p01', $M.toGetParam(params), {popupStatus : popupOption});
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" id="machine_doc_no" name="machine_doc_no" value="${bean.machine_doc_no}">
	<input type="hidden" id="machine_seq" name="machine_seq" value="${bean.machine_seq}">
	<input type="hidden" id="sale_mem_no" name="sale_mem_no" value="${bean.sale_mem_no}">
	<input type="hidden" id="sale_org_code" name="sale_org_code" value="${bean.sale_org_code}">
	<input type="hidden" id="recipient_cust_no" name="recipient_cust_no" value="${bean.recipient_cust_no}">
	<input type="hidden" id="buy_org_code" name="buy_org_code" value="${bean.buy_org_code}">
	<input type="hidden" id="inout_doc_no" name="inout_doc_no" value="${bean.inout_doc_no}">
	<input type="hidden" id="machine_used_no" name="machine_used_no" value="${bean.machine_used_no}"  >
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
				<table class="table-border mt5">
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
										<input type="text" class="form-control  width120px" value="${bean.display_no}" id="display_no" name="display_no"  readonly="readonly"  >									
									</div>

								</div>
							</td>					
							<th class="text-right">처리구분</th>
							<td>
								<input type="text" class="form-control  width120px" value="${bean.used_buy_status_name}" id="used_buy_status_name" name="used_buy_status_name"  readonly="readonly" >
							</td>													
							<th class="text-right">전차주명</th>
							<td>
								<div class="form-row inline-pd pr">
									<div class="col-6">
										<input type="text" class="form-control" value="${bean.old_cust_name}" id="old_cust_name" name="old_cust_name" readonly="readonly" >
									</div>
									<div class="col-6">								
									    <!-- 연관업무 버튼 마우스 오버시 레이어팝업 -->
    									<jsp:include page="/WEB-INF/jsp/common/commonMachineJob.jsp">  
                                            <jsp:param name="li_machine_type" value="__machine_doc_detail#__rental#__repair_history#__work_db"/>
                                        </jsp:include>
                                        <!-- /연관업무 버튼 마우스 오버시 레이어팝업 -->		
									</div>
								</div>									
							</td>		
							<th class="text-right">연락처</th>
							<td>
								<div class="input-group" >
									<input type="text" class="form-control  border-right-0" value="${bean.hp_no}" id="hp_no" name="hp_no" format="phone"  readonly="readonly"  >
									<button type="button" class="btn btn-icon btn-primary-gra"   onclick="javascript:fnSendSms();"><i class="material-iconsforum"></i></button>
								</div>
							</td>
						</tr>
						<tr>					
							<th class="text-right">메이커</th>
							<td>
								<input type="text" class="form-control  width120px" value="${bean.maker_name}" id="maker_name" name="maker_name" readonly="readonly"  >
							</td>
							<th class="text-right">모델명</th>
							<td>
								<input type="text" class="form-control  width120px" value="${bean.machine_name}" id="machine_name" name="machine_name"  readonly="readonly"  >
							</td>	
							<th class="text-right">차대번호</th>
							<td>
								<input type="text" class="form-control  width240px" value="${bean.body_no}"  id="body_no" name="body_no"  readonly="readonly"  >
							</td>	
							<th class="text-right">연식</th>
							<td>
								<input type="text" class="form-control width120px" value="${bean.reg_year}" id="reg_year" name="reg_year"   readonly="readonly" >
							</td>																		

						</tr>
						<tr>
						
							<th class="text-right">기종구분</th>
							<td>
								<input type="text" class="form-control  width120px"  value="${bean.part_name}"  id="part_name" name="part_name"    readonly="readonly"  >
							</td>
							<th class="text-right">규격구분</th>
							<td>
								<input type="text" class="form-control  width120px"  value="${bean.desc_name}" id="desc_name" name="desc_name"  readonly="readonly" >
							</td>							
							<th class="text-right">가동시간</th>
							<td>
								<input type="text" class="form-control  width120px"  value="${bean.op_hour}" id="op_hour" name="op_hour" readonly="readonly" >
							</td>							
							<th class="text-right">매입처</th>
							<td>
								<input type="text" class="form-control width120px" value="${bean.mng_org_name}" id="mng_org_name" name="mng_org_name" readonly="readonly" >
							</td>							
						</tr>

						<tr>
							<th class="text-right">매입가</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control text-right"  value="${bean.used_price}"  id="used_price" name="used_price" format="decimal" alt="매입가" readonly="readonly"  >
									</div>
									<div class="col width22px">원</div>
								</div>
							</td>
							<th class="text-right">품의가</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control text-right" value="${bean.agent_price}"  id="agent_price" name="agent_price"  format="decimal" alt="품의가"  readonly="readonly"   >
									</div>
									<div class="col width22px">원</div>
								</div>
							</td>
							<th class="text-right">특이사항</th>
							<td colspan="3">
								<input type="text" class="form-control" value="${bean.remark}"  id="remark" name="remark" alt="특이사항"  readonly="readonly"   >
							</td>				
	
						</tr>
						<tr>
							<th class="text-right">매입일</th>
							<td>
								<div class="input-group width120px">
									<input type="text" class="form-control border-right-0 calDate" ${bean.used_buy_status_cd == '5' ? 'disabled' : '' } id="taxbill_dt" name="taxbill_dt" dateformat="yyyy-MM-dd" alt="매입일" value="${bean.taxbill_dt}">
								</div>
							</td>									
							<th class="text-right">판매일자</th>
							<td>
								<div class="input-group width120px">
									<input type="text" class="form-control border-right-0 calDate" ${bean.used_buy_status_cd == '5' ? 'disabled' : '' } id="sale_dt" name="sale_dt" dateformat="yyyy-MM-dd" alt="판매일자" value="${bean.sale_dt}">
								</div>
							</td>
																									
							<th class="text-right">공급가액</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control text-right" value="${bean.agent_price}"  id ="supply_price" name="supply_price" alt="공급가액" format="decimal" readonly="readonly">
									</div>
									<div class="col width22px">원</div>
								</div>
							</td>
							<th class="text-right">실판매가</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control text-right"  ${bean.used_buy_status_cd == '5' ? 'readonly' : '' }  value="${ bean.contract_price > 0 ? bean.contract_price : bean.agent_price }" id ="contract_price" name="contract_price" alt="실판매가" format="decimal" onChange="javascript:fnCalcAmt();" >
									</div>
									<div class="col width22px">원</div>
								</div>
							</td>
							
						</tr>
						<tr>
							<th class="text-right">공급받는자</th>
							<td>
								<div class="input-group width120px">
									<input type="text" class="form-control border-right-0 width120px" value="${bean.recipient_cust_name}" id="recipient_cust_name" name="recipient_cust_name"  alt="공급받는자" readonly="readonly">
									<button type="button" class="btn btn-icon btn-primary-gra" ${bean.used_buy_status_cd == '5' ? 'disabled' : '' }  onclick="javascript:goCustInfoClick();"><i class="material-iconssearch"></i></button>							
								</div>
							</td>	
							<th class="text-right">판매자</th>
							<td>
								<div class="input-group width120px">
									<input type="text" class="form-control border-right-0" value="${bean.sale_mem_name}"  id ="sale_mem_name" name="sale_mem_name"  alt="판매자"  readonly="readonly" >
									<button type="button" class="btn btn-icon btn-primary-gra" ${bean.used_buy_status_cd == '5' ? 'disabled' : '' }  onclick="javascript:openMemberOrgPanel('setOrgMapPanel','N');" ><i class="material-iconssearch"></i></button>
								</div>
							</td>	
							<th class="text-right">손익</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control text-right" ${bean.used_buy_status_cd == '5' ? 'disabled' : '' } value="0" id ="used_loss_amt" name="used_loss_amt"  format="decimal" readonly="readonly" >
									</div>
									<div class="col width22px">원</div>
								</div>
							</td>	
							
							<th class="text-right">본사매입</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="checkbox" ${bean.used_buy_status_cd == '5' ? 'disabled' : '' }  name="used_buy_status_cd" id="used_buy_status_cd" value="Y" ${bean.used_buy_status_cd == '2'? 'checked="checked"' : ''}>
									<label class="form-check-label">본사매입</label>
								</div>
							</td>																						
						</tr>
						<tr>
							<th class="text-right">관리사항</th>
							<td colspan="7">
								<textarea class="form-control" style="height: 50px;" name="desc_text" id="desc_text" ${bean.used_buy_status_cd == '5' ? 'readonly' : '' } ><c:if test="${bean.desc_text eq ''}">${fn:trim(bean.machine_name )} / ${bean.body_no } / ${bean.machine_used_no }</c:if><c:if test="${bean.desc_text ne ''}">${bean.desc_text}</c:if></textarea>
							</td>				
						</tr>
					</tbody>
				</table>
			</div>
<!-- /폼테이블 -->	
				<div class="btn-group mt10">	
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
					</div>	
				</div>
<!-- 폼테이블2 ( 삭제 ) -->					
			
<!-- /폼테이블2-->	
<!-- 폼테이블3 -->					
			<div>
				<div class="title-wrap mt10">
					<h4>처리내역</h4>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 200px;"></div>
				<div class="btn-group mt10">	
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>	
				</div>
			</div>
<!-- /폼테이블3-->	
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>