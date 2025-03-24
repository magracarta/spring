<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 부품판매 > 매출처리 > 반품상세정보
-- 작성자 : 정윤수
-- 최초 작성일 : 2023-07-31 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
        var partReturnResultCd = "${info.part_return_result_cd}";

        $(document).ready(function() {
            if(partReturnResultCd != "01"){
                $("#_goCompleteApproval").addClass("dpn");
                $("#_goReturnReject").addClass("dpn");
                $("#reject_text").prop("readonly", true);
            }
            // 첨부파일 세팅
            <c:forEach var="list" items="${fileList}">fnPrintFile('${list.file_seq}', '${list.file_name}');</c:forEach>
        });
        
        // 첨부파일 출력
        function fnPrintFile(fileSeq, fileName) {
            var str = '';
            str += '<div class="table-attfile-item rep_file" style="float:left; display:block;">';
            str += '<a href="javascript:fileDownload(' + fileSeq + ');" style="color: blue; vertical-align: middle;">' + fileName + '</a>&nbsp;';
            str += '<input type="hidden" name="rep_file_seq" value="' + fileSeq + '"/>';
            str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
            str += '</div>';
            $('.file_div').append(str);
        }
        // 첨부파일세팅
        function setFileInfo(data) {

            var fileList = data; 
            for (var i = 0; i < fileList.length; i++) {
                if(fileList[i].file_seq != ""){
                    fnPrintFile(fileList[i].file_seq, fileList[i].file_name);
                }
            }
        }
        // 반품승인
        function goCompleteApproval() {
            var params = {
                "inout_doc_no" : $M.getValue("inout_doc_no"),
                "part_return_no" : $M.getValue("part_return_no"),
            };
            var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=780, left=0, top=0";
            $M.goNextPage('/cust/cust0202p01', $M.toGetParam(params), {popupStatus : popupOption});
        }
        // 반품반려
        function goReturnReject() {
            // 필수체크
            var frm = document.main_form;
            if($M.validation(frm) == false) {
                return false;
            }
            if($M.getValue("reject_text").trim() == "") {
                alert("반려사유는 필수입력사항입니다.");
                return false;
            }
            $M.goNextPageAjaxMsg("반려하시겠습니까?", this_page +  "/reject", $M.toValueForm(frm), {method : 'POST'},
                function(result) {
                    if(result.success) {
                        location.reload();
                    }
                }
            );
        }
        
        function fnClose() {
            window.close();
        }
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
    <input type="hidden" name="part_return_no" id="part_return_no" value="${info.part_return_no}">
    <input type="hidden" name="inout_doc_no" id="inout_doc_no" value="${info.inout_doc_no}">
    <input type="hidden" name="part_sale_no" id="part_sale_no" value="${info.part_sale_no}">
    <input type="hidden" name="send_invoice_seq" id="send_invoice_seq" value="${info.send_invoice_seq}">
    <input type="hidden" name="part_return_result_cd" id="part_return_result_cd" value="${info.part_return_result_cd}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
            <div class="title-wrap mt10">
                <h4>반품신청정보</h4>		
            </div>
<!-- 반품신청정보 테이블 -->
            <table class="table-border mt10">
                <colgroup>
                    <col width="100px">
                    <col width="">
                    <col width="100px">
                    <col width="">
                </colgroup>
                <tbody>
                    <tr>
                        <th class="text-right">반품신청일시</th>
                        <td>
                            <input type="text" class="form-control" value="${info.reg_date}" readonly>
                        </td>		
                        <th class="text-right">반품사유</th>
                        <td>
                            <input type="text" class="form-control" value="${info.part_return_reason_name}" readonly>
                            <input type="hidden" id="part_return_reason_cd" name="part_return_reason_cd" value="${info.part_return_reason_cd}">
                        </td>							
                    </tr>
                    <tr>
                        <th class="text-right">상세사유</th>
                        <td colspan="3">
                            <textarea class="form-control" placeholder="사유가 들어갑니다." id="desc_text" name="desc_text" readonly style="height: 70px;">${info.desc_text}</textarea>
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">사진</th>
                        <td colspan="3">
                            <div class="table-attfile file_div" style="width:100%;">
                                <div class="table-attfile" style="float:left">
                                </div>
                            </div>
                        </td>	
                    </tr>                    
                    			
                </tbody>
            </table>				
<!-- /반품신청정보 테이블 -->
            <div class="title-wrap mt10">
                <h4>배송정보</h4>
            </div>
<!-- 배송정보 테이블 -->
            <table class="table-border mt10">
                <colgroup>
                    <col width="100px">
                    <col width="">
                    <col width="100px">
                    <col width="">
                </colgroup>
                <tbody>
                <tr>
                    <th class="text-right">수령인</th>
                    <td>
                        <input type="text" class="form-control" readonly value="${info.receive_name}">
                        <input type="hidden" id="cust_no" name="cust_no" value="${info.cust_no}">
                    </td>
                    <th class="text-right">연락처</th>
                    <td>
                        <input type="text" class="form-control" readonly value="${info.receive_hp_no}">
                    </td>
                </tr>
                <tr>
                    <th class="text-right">주소</th>
                    <td colspan="3">
                        <c:choose>
                            <c:when test="${info.invoice_send_cd eq '5' and info.app_yn eq 'Y'}">
                                <div class="form-row inline-pd mb7">
                                    <div class="col-3">
                                        <input type="text" class="form-control" readonly value="">
                                    </div>
                                    <div class="col-9">
                                        <input type="text" class="form-control" readonly value="">
                                    </div>
                                </div>
                                <div class="form-row inline-pd ">
                                    <div class="col-12">
                                        <input type="text" class="form-control" readonly value="${info.invoice_desc_text}">
                                    </div>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="form-row inline-pd mb7">
                                    <div class="col-3">
                                        <input type="text" class="form-control" readonly value="${info.post_no}">
                                    </div>
                                    <div class="col-9">
                                        <input type="text" class="form-control" readonly value="${info.addr1}">
                                    </div>
                                </div>
                                <div class="form-row inline-pd ">
                                    <div class="col-12">
                                        <input type="text" class="form-control" readonly value="${info.addr2}">
                                    </div>
                                </div>
                            </c:otherwise>
                        </c:choose>
                        
                    </td>
                </tr>
                <tr>
                    <th class="text-right">배송메모</th>
                    <td colspan="3">
                        <input type="text" class="form-control" readonly value="${info.invoice_remark}">
                    </td>
                </tr>

                </tbody>
            </table>
<!-- /배송정보 테이블 -->
            <div class="title-wrap mt10">
                <h4>반품반려정보</h4>
            </div>
<!-- 반품반려정보 테이블 -->
            <table class="table-border mt10">
                <colgroup>
                    <col width="100px">
                    <col width="">
                    <col width="100px">
                    <col width="">
                </colgroup>
                <tbody>
                <tr>
                    <th class="text-right">반품반려일시</th>
                    <td>
                        <input type="text" class="form-control" readonly value="${info.reject_date}">
                    </td>
                    <th class="text-right">처리자</th>
                    <td>
                        <input type="text" class="form-control" readonly value="${info.proc_mem_name}" >
                    </td>
                </tr>
                <tr>
                    <th class="text-right">반려사유</th>
                    <td colspan="3">
                        <textarea class="form-control" placeholder="반품반려 시 반려사유는 필수입력!" id="reject_text" name="reject_text" style="height: 70px;">${info.reject_text}</textarea>
                    </td>
                </tr>
                </tbody>
            </table>
<!-- /반품반려정보 테이블 -->
			<div class="btn-group mt10">
				<div class="center">
                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_M"/></jsp:include>
                    <div class="right">
                        <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
                    </div>
				</div>
                
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>