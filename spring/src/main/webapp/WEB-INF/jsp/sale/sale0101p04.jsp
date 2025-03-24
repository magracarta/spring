<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 계약/출하 > null > 서류발송
-- 작성자 : 김태훈
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			if ($M.getValue("out_paper_send_type_name") == "") {
				$("button[onclick='javascript:goRemove();']").get(0).style.display = "none";
			} else {
				$("button[onclick='javascript:goSave();']").get(0).innerHTML = "수정";
			}
			if ($M.getValue("out_paper_send_dt") == "") {
				$M.setValue("out_paper_send_dt", "${inputParam.s_current_dt}");
			}
		});
	
		function fnClose() {
			setTimeout(function () {
				window.close();
            }, 100);
		}
		
		function fnJusoBiz(row) {
			console.log(row);
			var param = {
				out_paper_post_no: row.zipNo,
				out_paper_addr1: row.roadAddr,
				out_paper_addr2: row.addrDetail
            };
            $M.setValue(param);
		}
		
		function goSave() {
			if($M.validation(document.main_form) == false) {
				return false;
			}
			var frm = document.main_form;
			var msg = "저장하시겠습니까?";
			if ("${outDoc.out_paper_send_type_name}" !== "") {
				msg = "수정하시겠습니까?";
			}
			$M.goNextPageAjaxMsg(msg, this_page, $M.toValueForm(frm), {method: 'post'},
                  function (result) {
                       if (result.success) {
                    	   // location.reload();
                    	   fnClose();
                       }
                  }
             );
		}
		
		function goRemove() {
			var frm = document.main_form;
			var msg = "삭제하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, this_page+"/remove", $M.toValueForm(frm), {method: 'post'},
                  function (result) {
                       if (result.success) {
                    	   fnClose();
                       }
                  }
             );
		}
	
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="machine_out_doc_seq" name="machine_out_doc_seq" value="${inputParam.machine_out_doc_seq}">
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
					<h4 class="primary">출하서류발송</h4>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right rs">발송일자</th>
							<td>
								<div class="input-group width120px">
									<input type="text" class="form-control border-right-0 calDate rb" id="out_paper_send_dt" name="out_paper_send_dt" dateFormat="yyyy-MM-dd" required="required" value="${outDoc.out_paper_send_dt}">
								</div>
							</td>									
						</tr>	
						<tr>
							<th class="text-right rs">발송구분</th>
							<td>
								<input type="text" name="out_paper_send_type_name" id="out_paper_send_type_name" class="form-control" value="${outDoc.out_paper_send_type_name}" required="required" maxlength="6">
							</td>									
						</tr>						
						<tr>
							<th class="text-right rs">발송지</th>
							<td>
								<div class="form-row inline-pd mb7">
									<div class="col-2">
										<input type="text" class="form-control" readonly="readonly" id="out_paper_post_no" name="out_paper_post_no" alt="출하서류우편번호" value="${outDoc.out_paper_post_no}" required="required">
									</div>
									<div class="col-2">
										<button type="button" class="btn btn-primary-gra" style="width: 100%" onclick="javascript:openSearchAddrPanel('fnJusoBiz');">주소찾기</button>
									</div>					
									<div class="col-8">
										<input type="text" class="form-control" readonly="readonly"  id="out_paper_addr1" name="out_paper_addr1" alt="출하서류주소1" value="${outDoc.out_paper_addr1}" required="required">
									</div>				
								</div>
								<div class="form-row inline-pd">								
									<div class="col-12">
										<input type="text" class="form-control"  id="out_paper_addr2" name="out_paper_addr2" alt="출하서류주소2" value="${outDoc.out_paper_addr2}" maxlength="74">
									</div>				
								</div>
							</td>									
						</tr>	
					</tbody>
				</table>
			</div>		
<!-- /폼테이블 -->
			<div class="btn-group mt10">
				<div class="right" id="btnHide">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>