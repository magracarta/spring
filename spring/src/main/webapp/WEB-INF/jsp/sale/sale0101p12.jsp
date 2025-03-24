<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 계약/출하 > null > 장비세금계산서 관리
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-09-09 11:00:34
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
		function fnClose() {
			window.close();
		}
		
		function goBillCheckPopup() {
            var param = {
            	inout_doc_no : "${inputParam.inout_doc_no}"
            }
            var poppupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=375, height=340, left=0, top=0";
            $M.goNextPage('/sale/sale0101p05', $M.toGetParam(param), {popupStatus : poppupOption});
        }
		
		function goBregOpen() {
			/* if ("${item.end_yn}" == "Y") {
				alert("마감된 전표입니다.");
				return false;
			} */
			if ("${item.report_yn}" == "Y") {
				alert("국세청신고된 전표입니다.");
				return false;
			}
			if ("${item.duzon_trans_yn}" == "Y") {
				alert("회계전송된 전표입니다.");
				return false;
			}
			var param = {
	    			 's_cust_no' : "${item.cust_no}"
	    	};
	    	openSearchBregSpecPanel('goChangeBreg', $M.toGetParam(param));
		}
		
		function goChangeBreg(row) {
			var param = {
				cust_no : "${item.cust_no}",
				cust_name : "${item.cust_name}",
				inout_doc_no : "${item.inout_doc_no}",
				breg_seq : row.breg_seq,
				breg_no : $M.removeHyphenFormat(row.breg_no),
				biz_addr1: row.biz_addr1,
				biz_addr2: row.biz_addr2,
				biz_post_no: row.biz_post_no,
				breg_cor_part: row.breg_cor_part,
				breg_cor_type: row.breg_cor_type,
				breg_name: row.breg_name,
				breg_no: row.breg_no,
				breg_rep_name: row.breg_rep_name,
				breg_seq: row.breg_seq,
				breg_type_cd: row.breg_type_cd
			};
			if ("${item.taxbill_no}" != "") {
				param["taxbill_no"] = "${item.taxbill_no}"; 
			}
			console.log(param);
			$M.goNextPageAjax("/sale/sale0101p12/changeBreg", $M.toGetParam(param), {method : 'POST'},
					function(result) {
				    	if(result.success) {
				    		alert("처리가 완료됐습니다. 세금계산서 관리메뉴에서 변경된 내용이 적용되었는지 확인하세요.");	
				    		location.reload();
						}
					}
				);
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<div class="popup-wrap width-100per" style="min-width: 698px;">
<input type="hidden" name="s_cust_no" value="${item.cust_no }">
<!-- 타이틀영역 -->
        <div class="main-title">
            <h2>장비세금계산서 관리</h2>
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
					</colgroup>
					<tbody>
                        <tr>
                            <th class="text-right">전표일자 - 번호</th>
                            <td>
                                <div class="form-row inline-pd widthfix" style="min-width: 300px">
									<div class="col-auto">
										${item.inout_dt } - ${item.inout_doc_no }
									</div>
									<div class="col width100px text-secondary">
										마감완료
									</div>
								</div>
                            </td>
                            <th class="text-right">세금계산서번호</th>
                            <td>
                                <div class="form-row inline-pd widthfix">
                                    <div class="col width140px">
                                        <input type="text" class="form-control" value="${item.taxbill_no }" disabled="disabled">
                                    </div>
                                    <!-- <div class="col width16px text-center">~</div>
                                    <div class="col width50px">
                                        <input type="text" class="form-control">
                                    </div> -->
                                    <div class="col width16px text-center">-</div>
                                    <div class="col width33px">
                                        <input type="text" class="form-control" value="${item.taxbill_control_no}" disabled="disabled">
                                    </div>
                                    <div class="col-auto text-secondary">
										<c:choose>
											<c:when test="${'N' eq item.report_yn}">미확인</c:when>
											<c:when test="${'Y' eq item.report_yn}">국세청신고</c:when>
										</c:choose>
										<c:if test="${item.duzon_trans_yn}">
											<div>회계전송</div>
										</c:if>
                                    </div>                                    
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right">고객명</th>
                            <td colspan="3">
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control" disabled="disabled" value="${item.cust_name }">
									</div>
									<div class="col width200px">
										<input type="text" class="form-control" disabled="disabled" value="${item.hp_no }" format="phone" id="hp_no" name="hp_no">
									</div>
								</div>
							</td>
                        </tr>
                        <tr>
                            <th class="text-right">주소</th>
                            <td colspan="3">
                                <div class="form-row inline-pd mb7">
                                    <div class="col width100px">
                                        <input type="text" class="form-control" disabled="disabled" value="${item.biz_post_no }">
                                    </div>
                                    <div class="col width280px">
                                        <input type="text" class="form-control" disabled="disabled" value="${item.biz_addr1 }">
                                    </div>
                                </div>
                                <div class="form-row inline-pd">
                                    <div class="col-12">
                                        <input type="text" class="form-control" disabled="disabled" value="${item.biz_addr2 }">
                                    </div>		
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right">사업자No.</th>
                            <td colspan="3">
								<div class="form-row inline-pd widthfix">
									<div class="col width160px">
										<input type="text" class="form-control" readonly="readonly" value="${item.breg_no }" format="bregno" id="breg_no" name="breg_no">
									</div>
									<div class="col-auto pl5">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" checked="checked" disabled="disabled">
											<label class="form-check-label">사업자확인</label>
										</div>
									</div>
									<div class="col" style="width: calc(50% - 100px);">
										<button type="button" class="btn btn-primary-gra" onclick="javascript:goBregOpen()">변경</button>
									</div>
								</div>
							</td>
                        </tr>
                        <tr>
                            <th class="text-right">업체명</th>
                            <td colspan="3">
								<div class="form-row inline-pd widthfix">
									<div class="col width200px">
										<input type="text" class="form-control" disabled="disabled" value="${item.breg_name }">
									</div>
									<div class="col width100px">
										<input type="text" class="form-control" disabled="disabled" value="${item.breg_rep_name }">
									</div>
								</div>
							</td>
                        </tr>
                        <tr>
                            <th class="text-right">업태 종목</th>
                            <td colspan="3">
								<div class="form-row inline-pd widthfix">
									<div class="col width150px">
										<input type="text" class="form-control" disabled="disabled" value="${item.breg_cor_type }">
									</div>
									<div class="col width150px">
										<input type="text" class="form-control" disabled="disabled" value="${item.breg_cor_part }">
									</div>
								</div>
							</td>
                        </tr>
                        <tr>
                            <th class="text-right">FAX</th>
                            <td>
                                <div class="form-row inline-pd widthfix">
									<div class="col width150px">
										<input type="text" class="form-control" disabled="disabled" value="${item.fax_no }" format="tel" id="fax_no" name="fax_no">
									</div>
								</div>
                            </td>
                            <th class="text-right">매출한도</th>
                            <td>
                                <div class="form-row inline-pd widthfix">
									<div class="col width150px">
										<input type="text" class="form-control text-right" disabled="disabled" value="${item.max_misu_amt }" id="max_misu_amt" name="max_misu_amt" format="decimal">
									</div>
								</div>
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right">현미수금액</th>
                            <td>
                                <div class="form-row inline-pd widthfix">
									<div class="col width150px">
										<input type="text" class="form-control text-right" disabled="disabled" value="${item.misu_amt }" id="misu_amt" name="misu_amt" format="decimal">
									</div>
								</div>
                            </td>
                            <th class="text-right">쿠폰잔액</th>
                            <td>
                                <div class="form-row inline-pd widthfix">
									<div class="col width150px">
										<input type="text" class="form-control text-right" disabled="disabled" value="${item.buy_amt }" id="buy_amt" name="buy_amt" format="decimal">
									</div>
								</div>
                            </td>
                        </tr>
					</tbody>
				</table>
			</div>		
<!-- /폼테이블 -->
			<div class="btn-group mt10">
				<div class="right">
					<button type="button" class="btn btn-info" onclick="javascript:goBillCheckPopup()">세금계산서</button>
					<button type="button" class="btn btn-info" onclick="javascript:fnClose()">닫기</button>
				</div>
			</div>
        </div>
    </div>	
</form>
</body>
</html>