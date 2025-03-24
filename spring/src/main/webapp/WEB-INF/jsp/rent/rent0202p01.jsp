<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈대장 > 어태치먼트대장 > null > 어태치먼트 상세정보
-- 작성자 : 김상덕
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript" src="/static/js/qrcode.min.js"></script>
	<script type="text/javascript">
	
		// 기타매입처일 경우 비고 필수입력, 추후 cust_no 변경 -> 이런기능 필요없어서 주석함.
		// var etcClient = "20200722000000001";
	
		$(document).ready(function() {
			// qr코드 그리기
			if (${not empty item.qr_no}) {
				new QRCode(document.getElementById("qr_image"), {
					text: "${item.qr_no}",
					width: 50,
					height: 50,
				});
				$("#qr_image > img").css({"margin":"auto"});
			} else {
				$("#qr_image").html("미등록");
			}

			if ("${item.rental_pos_status_cd}" == "9") {
				$("#_goRentalSalePopup").hide();
			} else {
				$("#_goRentalSaleInfoPopup").hide();
			}

// 			$M.setValue(${item});
			// fnCalc();
			if ("${item.machine_doc_no}" != "") {
				$("#docBtn").css("display", "block");
			}
			fnSetReduceYn();
		});
		
		// 매입처
		function fnSetClient(row) {
			console.log(row);
			var param = {
				client_cust_name : row.cust_name,
			}
			$M.setValue(param);
		}

		// 렌탈이력
	    function goRentalHisPopup() {
	     	var params = {
	     		rental_attach_no : "${inputParam.rental_attach_no}"
	     	};
			var popupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=430, left=0, top=0";
			$M.goNextPage('/rent/rent0201p04', $M.toGetParam(params), {popupStatus : popupOption});
	    }
		
		//이동이력
	    function goMoveHisPopup() {
	     	var params = {
	     		rental_attach_no : "${inputParam.rental_attach_no}"
	     		, custom_menu_name : "렌탈어테치먼트 이동이력" // Q&A 11480 렌탈상세에서 이동이력 호출시 메뉴명 변경 by 김상덕 210513
	     	};
			var popupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=430, left=0, top=0";
			$M.goNextPage('/rent/rent0201p05', $M.toGetParam(params), {popupStatus : popupOption});
	
	    }
		
	  	//수리이력(수리금액 0원임)
	    /* function goAsHisPop() {
	     	alert("수리이력");
	    } */
	  	
	  	//판매이력
	    function goSaleHisPop() {
	    	var params = {
	     		rental_attach_no : "${inputParam.rental_attach_no}"
	     	};
			var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=430, left=0, top=0";
			$M.goNextPage('/rent/rent0201p06', $M.toGetParam(params), {popupStatus : popupOption});
	    }
		
		//판매처리
	    function goRentalSalePopup() {
	    	var params = {
	     		rental_attach_no : "${inputParam.rental_attach_no}",
	     		attach_sale_yn : "Y"
	     	};
			var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=450, height=550, left=0, top=0";
			$M.goNextPage('/rent/rent0201p02', $M.toGetParam(params), {popupStatus : popupOption});
	    }
		
		// 품의서 조회
		function goMachineDoc() {
			var param = {
				machine_doc_no : "${item.machine_doc_no}"
			};
			var poppupOption = "";
	    	$M.goNextPage("/sale/sale0101p03", $M.toGetParam(param), {popupStatus : poppupOption});
		}
		
		function fnCalc() {
			
			// 뷰에서 가져오는걸 사용
			return false;
			// 운영월수 = 매입일자부터 오늘까지 개월 수(소수첫째짜리까지 표현)
			var todayDt = "${inputParam.s_current_dt}";
			var buyDt = $M.getValue("buy_dt");
			var diff = $M.getDiff(todayDt, buyDt, {isEqualZero: true});
			console.log("운영일수 : ", diff);
			// 소수점 2째에서 올림 지시 
			var opMonth = Math.round((diff/30)*10)/10;
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
			
			// 수리비용(어태치 수리비용 확인필요)
			var repair = 0;
			
			// 최종 어태치 가액(구명칭 : 최종가액) = 어태치가액 + 수리비용
			var finalAttach = attach + repair;
			
			// 월감가액
			var depreciation = $M.toNum($M.getValue("reduce_price"));
			
			// 감가총액 = 월감가액 * 운영월수
			var totalDepreciation = depreciation * opMonth;
			
			// 최소판가 = 어태치가액 + 수리비용 - 감가총액 
			var minSalePrice = attach - totalDepreciation;
			
			var param = {
				op_month : opMonth
				, interest_amt : interest
				, repair : repair
				, final_attach : finalAttach
				, total_reduce_price : totalDepreciation
				, min_sale_price : minSalePrice
			}
			
			$M.setValue(param);
			
		}
	
	    function goModify() {
	    	var frm = document.main_form;
			if ($M.getValue("reduce_yn") == "Y") {
				if($M.validation(frm, {field:["reduce_st_dt"]}) == false) { 
					return;
				}
				if($M.checkRangeByFieldName('reduce_st_dt', 'reduce_ed_dt', true) == false) {
					return;
				};				
			} else {
				if($M.validation(frm) == false) { 
					return;
				}
			}
			$M.goNextPageAjaxModify(this_page + '/modify', $M.toValueForm(frm) , {method : 'POST'},
				function(result) {
					if(result.success) {
						alert("처리가 완료되었습니다.");
						window.location.reload();
						//opener.goSearch();
					}
				}
			);
	    }
		
	    function goRemove() {
	    	var rental_attach_no = "${item.rental_attach_no}";
	    	$M.goNextPageAjaxRemove(this_page + '/remove/' + rental_attach_no, "", {method : 'POST'},
	   			function(result) {
	   				if(result.success) {
						fnClose();
						if (opener != null && opener.goSearch) {
							opener.goSearch();
						}
	   				}
	   			}
	   		);
	    }
	    
	    function fnClose() {
	    	window.close();
	    }
		
	    function fnSetReduceYn() {
	    	var reduceYn = $M.getValue("reduce_yn");
	    	if (reduceYn == "Y") {
	    		$("#reduce_st_dt").prop("readonly", false);
	    		$("#reduce_ed_dt").prop("readonly", false);
	    		$(".r1s").addClass("rs");
	    		$(".r1b").addClass("rb");	    		
	    	} else {
	    		$("#reduce_st_dt").prop("readonly", true);
	    		$("#reduce_ed_dt").prop("readonly", true);
	    		$(".r1s").removeClass("rs");
	    		$(".r1b").removeClass("rb");
	    	}
	    };

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
				, part_no_machine : row.part_no_machine
			};
			$M.setValue(param);
			fnCalc();
		}

		function show() {
			document.getElementById("help_operation").style.display="block";
		}
		function hide() {
			document.getElementById("help_operation").style.display="none";
		}
		
	</script>
</head>
<body   class="bg-white"  >
<form id="main_form" name="main_form">
<input type="hidden" id="rental_machine_no" name="rental_machine_no" value="${item.rental_machine_no }">
<input type="hidden" id="interest_rate" name="interest_rate" value="${item.interest_rate}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per" style="min-width: 1000px">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
			<div class="title-wrap">
				<h4>어태치먼트 상세정보</h4>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
				</div>
			</div>	
<!-- 폼 테이블 -->			
			<table class="table-border mt5">
				<colgroup>
					<col width="100px">
					<col width="200px">
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
									<input type="text" class="form-control" readonly="readonly" id="rental_attach_no" name="rental_attach_no" value="${item.rental_attach_no}">
								</div>
								<div class="col width70px" id="docBtn" style="display: none;">
									<button class="btn btn-default" onclick="javascript:goMachineDoc()">출하의뢰서조회</button>
								</div>
							</div>
						</td>
						<th class="text-right">매입일자</th>
						<td>
							<div class="input-group width100px">
								<input type="text" class="form-control border-right-0 calDate" dateFormat="yyyy-MM-dd" id="buy_dt" name="buy_dt" value="${item.buy_dt}" alt="매입일자" disabled="disabled">
							</div>
						</td>
						<th class="text-right rs">소유센터</th>
						<td>
							<select class="form-control rb" id="own_org_code" name="own_org_code" required="required" alt="소유센터">
								<option value="">- 선택 -</option>
								<c:forEach var="orgitem" items="${orgCenterList}">
									<option value="${orgitem.org_code}" ${orgitem.org_code eq item.own_org_code ? 'selected="selected"' : ''}>${orgitem.org_name}</option>
								</c:forEach>
								<option value="5010">서비스지원</option>
							</select>
						</td>
						<th class="text-right">유/무상여부</th>
						<td>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" id="cost_yn_y" value="Y" name="cost_yn" ${item.cost_yn eq 'Y' ? 'checked="checked"' : ''} disabled>
								<label class="form-check-label" for="cost_yn_y">유상</label>
							</div>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" value="N" id="cost_yn_n" name="cost_yn" ${item.cost_yn eq 'N' ? 'checked="checked"' : ''} disabled>
								<label class="form-check-label" for="cost_yn_n">무상</label>
							</div>									
						</td>						
					</tr>
					<tr>
						<th class="text-right">매입처</th>
						<td>
							<div class="input-group">
								<input type="text" class="form-control border-right-0" id="client_cust_name" name="client_cust_name" value="${item.client_cust_name}">
								<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchClientPanel('fnSetClient');"><i class="material-iconssearch"></i></button>
							</div>
						</td>
						<th class="text-right">매입가격</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" readonly="readonly" id="buy_price" name="buy_price" value="${item.buy_price}" format="decimal">
								</div>
								<div class="col width16px">원</div>
							</div>
						</td>
						</td>
						<th class="text-right rs">관리센터</th>
						<td>
							<select class="form-control rb" id="mng_org_code" name="mng_org_code" required="required" alt="관리센터">
								<option value="">- 선택 -</option>
								<c:forEach var="orgitem" items="${orgCenterList}">
									<option value="${orgitem.org_code}" ${orgitem.org_code eq item.mng_org_code ? 'selected="selected"' : ''}>${orgitem.org_name}</option>
								</c:forEach>
								<option value="5010">서비스지원</option>
							</select>
						</td>
						<th class="text-right">렌탈매출</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" readonly="readonly" id="b" name="b" value="${item.rental_sale}" format="decimal">
								</div>
								<div class="col width16px">원</div>
							</div>
						</td>					
					</tr>
					<tr>
						<th class="text-right">어태치먼트명</th>
						<td>
							<div class="input-group">
								<input type="text" class="form-control border-right-0" readonly="readonly" id="attach_name" name="attach_name" value="${item.attach_name}">
<%--								<button type="button" class="btn btn-icon btn-primary-gra" disabled="disabled"><i class="material-iconssearch"></i></button>--%>
								<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goAttachPopup();" ><i class="material-iconssearch"></i></button>
							</div>
						</td>
						<th class="text-right">이자금액</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" readonly="readonly" id="interest_amt" name="interest_amt" value="${item.interest_amt}" format="decimal">
								</div>
								<div class="col width16px">원</div>
							</div>
						</td>
						<th class="text-right">감가여부</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width130px">
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" value="Y" id="reduce_yn_y" name="reduce_yn" ${item.reduce_yn eq 'Y' ? 'checked="checked"' : ''} onclick="javascript:fnSetReduceYn()">
										<label class="form-check-label" for="reduce_yn_y">적용</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" value="N" id="reduce_yn_n" name="reduce_yn" ${item.reduce_yn eq 'N' ? 'checked="checked"' : ''} onclick="javascript:fnSetReduceYn()">
										<label class="form-check-label" for="reduce_yn_n">미적용</label>
									</div>
								</div>									
							</div>	
						</td>
						<th class="text-right">월감가액</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" id="reduce_price" name="reduce_price" value="${item.reduce_price}" onchange="javascript:fnCalc()" format="decimal">
								</div>
								<div class="col width16px">원</div>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">부품번호</th>
						<td>
							<div>
								<input type="text" class="form-control" id="part_no_machine" name="part_no_machine" alt="모델명" readonly="readonly" value="${item.part_no_machine}">
								<input type="hidden" class="form-control width120px" readonly="readonly" id="part_no" name="part_no" value="${item.part_no}">
							</div>
						</td>
						<th class="text-right">수리금액</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" readonly="readonly" id="a" name="a" value="${item.a}" format="decimal">
								</div>
								<div class="col width16px">원</div>
							</div>
						</td>
						<th class="text-right r1s">감가시작일</th>
						<td>
							<div class="input-group width100px">
								<input type="text" class="form-control border-right-0 calDate r1b" id="reduce_st_dt" name="reduce_st_dt" dateFormat="yyyy-MM-dd" value="${item.reduce_st_dt}"  alt="감가시작일">
							</div>
						</td>
						<th class="text-right">감가총액</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" readonly="readonly" id="total_reduce_price" name="total_reduce_price" value="${item.total_reduce_price}" format="decimal">
								</div>
								<div class="col width16px">원</div>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">일련번호</th>
						<td>
							<input type="text" class="form-control" id="product_no" name="product_no" value="${item.product_no}">
						</td>
						<th class="text-right">최종 어태치가액</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" readonly="readonly" id="part_total_amt" name="part_total_amt" value="${item.final_attach_price}" format="decimal">
								</div>
								<div class="col width16px">원</div>
							</div>
						</td>
						<th class="text-right">감가종료일</th>
						<td>
							<div class="input-group width100px">
								<input type="text" class="form-control border-right-0 calDate" id="reduce_ed_dt" name="reduce_ed_dt" dateFormat="yyyy-MM-dd" value="${item.reduce_ed_dt}" alt="감가 종료일">
							</div>
						</td>
						<th class="text-right">최소판가</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" readonly="readonly" id="min_sale_price" name="min_sale_price" value="${item.min_sale_price}" format="decimal">
								</div>
								<div class="col width16px">원</div>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">잔존가
							<i class="material-iconserror font-16" style="vertical-align: middle;" onmouseover="javascript:show()" onmouseout="javascript:hide()"></i>
						</th>
						<div class="con-info" id="help_operation" style="max-height: 500px; top: 75%; left: 4%; width: 105px; display: none;">
							<ul class="">
								<ol style="color: #666;">매입가격-렌탈매출</ol>
							</ul>
						</div>
						<td>
							<input type="text" class="form-control text-right" readonly="readonly" id="residual_price" name="residual_price" value="${item.residual_price}" format="decimal">
						</td>
						<th class="text-right">운영월수</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" readonly="readonly" id="op_month" name="op_month" format="decimal" value="${item.op_month }">
								</div>
							</div>
						</td>
						<th class="text-right">기본여부</th>
						<td>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" ${item.base_yn eq 'Y' ? 'checked' : '' }
									name="base_yn" id="base_yn_y" value="Y" disabled="disabled"> 
									<label for="base_yn_y" class="form-check-label">Y</label>
							</div>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" ${item.base_yn eq 'N' ? 'checked' : '' }
									name="base_yn" id="base_yn_n" value="N" disabled="disabled">
								<label for="base_yn_n" class="form-check-label">N</label>
							</div>
						</td>
						<th class="text-right">QR이미지</th>
						<td>
							<div id="qr_image" name="qr_image">
								<input type="hidden" id="qr_no" name="qr_no" value="${item.qr_no}">
							</div>
						</td>
					</tr>			
					<tr>
						<th class="text-right">비고</th>
						<td colspan="5">
							<input type="text" class="form-control" id="remark" name="remark" value="${item.remark }">
						</td>
            <th class="text-right">판매일자</th>
            <td>
              <div class="input-group width100px">
                <input type="text" class="form-control border-right-0 calDate" dateFormat="yyyy-MM-dd" id="sale_dt" name="sale_dt" value="${item.sale_dt}" alt="판매일자" disabled="disabled">
              </div>
            </td>
					</tr>
				</tbody>
			</table>			
<!-- /폼 테이블 -->	
			<div class="btn-group mt10">
				<div class="right">
					<button type="button" id="_goRentalSaleInfoPopup" class="btn btn-info" onclick="javascript:goRentalSalePopup();">판매정보</button>
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>