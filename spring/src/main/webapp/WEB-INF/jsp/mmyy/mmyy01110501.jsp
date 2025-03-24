<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 경조금 지급 신청서 > 경조금 지급 신청서 등록 > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-05-10 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	// 경조구분
	var docMoneyTypeJson = JSON.parse('${codeMapJsonObj['DOC_MONEY_TYPE']}');
	
	$(document).ready(function() {
		var data = ${infoJson}
		
		// 관리부가 아닐경우 신청자 disabled 처리
		// 2021-07-12 : 다른직원이 대신 등록할 경우도 있으므로 disabled 처리 해제
// 		if (${inputParam.org_code} != 2000) {
// 			$("#s_web_id").prop("disabled", true);
// 			$('[name="__mem_search_btn"]').prop("disabled", true);
// 		}
			
			$M.setValue("___mem_name", data.kor_name);
			$M.setValue("s_web_id", data.web_id);
			$M.setValue("apply_mem_no", data.mem_no);
			$M.setValue("org_code", data.org_code);
			$M.setValue("org_name", data.org_name);
			$M.setValue("grade_cd", data.grade_cd);
			$M.setValue("grade_name", data.grade_name);
			$M.setValue("job_cd", data.job_cd);
			$M.setValue("hp_no", data.hp_no);
			$M.setValue("ipsa_dt", data.ipsa_dt);
			$M.setValue("home_post_no", data.home_post_no);
			$M.setValue("home_addr1", data.home_addr1);
			$M.setValue("home_addr2", data.home_addr2);
			$("#org_name_text").html(data.org_name);
			$("#reg_mem_name_text").html(data.kor_name);
	});
	
	// 첨부파일의 index 변수
	var fileIndex = 1;
	// 첨부할 수 있는 파일의 개수
	var fileCount = 5;
	
	function fnList() {
// 		history.back();
		
		var param = {
				"init_yn" : "Y"
			}
		$M.goNextPage("/mmyy/mmyy011105", $M.toGetParam(param));
	}
	
	function fnAddFile() {
		if($("input[name='file_seq']").size() >= fileCount) {
			alert("파일은 " + fileCount + "개만 첨부하실 수 있습니다.");
			return false;
		}
		
		var param = {
			upload_type	: "DOC",
			file_type : "both",
		};
		
		openFileUploadPanel('setFileInfo', $M.toGetParam(param));
		
	}
	
	function setFileInfo(result) {
		var str = ''; 
		str += '<div class="table-attfile-item doc_file_' + fileIndex + '" style="float:left; display:block;">';
		str += '<a href="javascript:fileDownload(' + result.file_seq + ');" style="color: blue;">' + result.file_name + '</a>&nbsp;';
		str += '<input type="hidden" name="file_seq" value="' + result.file_seq + '"/>';
		str += '<button type="button" class="btn-default" onclick="javascript:fnRemoveFile(' + fileIndex + ', ' + result.file_seq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
		str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
		str += '</div>';
		$('.doc_file_div').append(str);
		fileIndex++;
	}
	
	// 첨부파일 삭제
	function fnRemoveFile(fileIndex, fileSeq) {
		var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
		if (result) {
			$(".doc_file_" + fileIndex).remove();
		} else {
			return false;
		}
		
	}
	
	// 결재요청
	function goRequestApproval() {
		goSave('requestAppr');
	}
	
	// 저장
	function goSave(isRequestAppr) {
		if ($M.getValue("apply_mem_no") == "") {
			alert("신청자는 필수 입력입니다.")
			return;
		}
		
		// validation check
		if($M.validation(document.main_form) == false) {
			return;
		};
		
		if ($M.getValue("money_amt") == 0) {
			alert("경조금액을 입력해 주세요.");
			$("#money_amt").focus();
			return;
		}
		
		var msg = "";
		if (isRequestAppr != undefined) {
			$M.setValue("save_mode", "appr"); // 결재요청
			msg = "결재요청 하시겠습니까?";
		} else {
			$M.setValue("save_mode", "save"); // 저장
			msg = "저장 하시겠습니까?";
		}

        if (confirm(msg) == false) {
            return false;
        }

		var idx = 1;
		$("input[name='file_seq']").each(function() {
			var str = 'doc_file_seq_' + idx;
            if ($(this).attr("id") == undefined || $(this).attr("id") == '') {
                $M.setValue(str, $(this).val());
            }
			idx++;
		});

		for(; idx <= fileCount; idx++) {
			$M.setValue('doc_file_seq_' + idx, '');
		}

		var frm = $M.toValueForm(document.main_form);

		console.log(frm);
		
		$M.goNextPageAjax(this_page + "/save", frm , {method : 'POST'},
			function(result) {
	    		if(result.success) {
	    			fnList();
				}
			}
		);
	}
	
	// 경조구분 변경시
	function fnDocMoneyTypeSet(data) {
		// 입사일 기준으로 경조금액이 달라지기 때문에 신청자를 먼저 입력받음.
		if ($M.getValue("apply_mem_no") == "") {
			alert("신청자를 먼저 입력해 주세요.");
			$M.setValue("doc_money_type_cd", "");
			return false;
		}
		
		// 경조금액 수정 제어
		fnMoneyAmtControl();
		
		var docMoneyTypeCd = data;
		$M.setValue("money_amt", 0);
		
		if (docMoneyTypeCd != "") {
			var param = {
				"doc_money_type_cd" : docMoneyTypeCd
			};
			
			$M.goNextPageAjax(this_page + "/search/money/def", $M.toGetParam(param) , {method : 'GET'},
				function(result) {
		    		if(result.success) {
		    			var list = result.list; // 경조대상 리스트
		    			var codeList = result.code_list;
		    			$("#doc_money_man_type_cd option").remove();
		    			
		    			$("#doc_money_man_type_cd").append(new Option('- 선택 -', ""));
		    			
		    			for (item in list) {
		    				$("#doc_money_man_type_cd").append(new Option(list[item].doc_money_man_type_name, list[item].doc_money_man_type_cd));
		    			}
					}
				}
			);
		} else {
			// 경조구분이 선택일경우
			$("#doc_money_man_type_cd option").remove();
			$("#doc_money_man_type_cd").append(new Option('- 선택 -', ""));
		}
		
	}
	
	// 경조구분의 code_v2값 (Y : 수정가능) 에 따라 경조금액 수정 제어
	function fnMoneyAmtControl() {
		var editAmtYn = false;
		
		for (var i = 0; i < docMoneyTypeJson.length; i++) {
			if (docMoneyTypeJson[i].code_value == $M.getValue("doc_money_type_cd")) {
				if (docMoneyTypeJson[i].code_v2 == "Y") {
					editAmtYn = true;
				}
			}
		}
		
		if (editAmtYn) {
			$("#money_amt").removeAttr("readonly");
		} else {
			$("#money_amt").attr("readonly", true);
		}
	}
	
	// 경조대상 변경시
	function fnGetMoneyAmt(data) {
		var docMoneyManTypeCd = data;
		// 경조금액 수정 제어
		fnMoneyAmtControl();
		
		var param = {
				"doc_money_type_cd" : $M.getValue("doc_money_type_cd"),
				"doc_money_man_type_cd" : docMoneyManTypeCd,
				"mem_no" : $M.getValue("s_mem_no"),
				"ipsa_dt" : $M.getValue("ipsa_dt")
		}
		
		if (docMoneyManTypeCd != "") {
			$M.goNextPageAjax(this_page + "/get/money/amt", $M.toGetParam(param) , {method : 'GET'},
				function(result) {
		    		if(result.success) {
		    			$M.setValue("money_amt", result.money_amt);
					}
				}
			);			
		}
	}
	
	// 직원조회
	// 관리부일경우 신청자 선택하여 정보 세팅.
	function setMemberOrgMapPanel(data) {
		$M.setValue("apply_mem_no", data.mem_no);
		$M.setValue("org_code", data.org_code);
		$M.setValue("org_name", data.org_name);
		$M.setValue("grade_cd", data.grade_cd);
		$M.setValue("grade_name", data.grade_name);
		$M.setValue("job_cd", data.job_cd);
		$M.setValue("hp_no", data.hp_no_real);
		$M.setValue("ipsa_dt", data.ipsa_dt);
// 		$M.setValue("retire_dt", data.retire_dt);
		$M.setValue("home_post_no", data.home_post_no);
		$M.setValue("home_addr1", data.home_addr1);
		$M.setValue("home_addr2", data.home_addr2);
// 		$M.setValue("addr", data.home_addr1 + ' ' + data.home_addr2);
		$("#org_name_text").html(data.org_name);
		$("#reg_mem_name_text").html(data.mem_name);
	}


    // 경조금 수정
    function goReplyModify(){
        $M.goNextPage('/mmyy/mmyy01110401p01', $M.toGetParam({}), {popupStatus : getPopupProp(800, 400)});
    }
	
	</script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
<input type="hidden" id="ipsa_dt" name="ipsa_dt">
<input type="hidden" id="s_current_dt" name="s_current_dt" value="${inputParam.s_current_dt}">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 상세페이지 타이틀 -->
				<div class="main-title detail width780px">
					<div class="detail-left">
						<button type="button" class="btn btn-outline-light" onclick="javascript:fnList()"><i class="material-iconskeyboard_backspace text-default"></i></button>
<%-- 						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/> --%>
						<h2>경조금지급신청서 등록</h2>
                    </div>
<!-- 결재영역 -->
					<div class="p10" style="margin-left: 10px;">
						<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
					</div>
<!-- /결재영역 -->
				</div>
<!-- /상세페이지 타이틀 -->
				<div class="contents">
<!-- 폼테이블 -->					
                    <table class="table-border width750px">
                        <colgroup>
                            <col width="100px">
                            <col width="">
                            <col width="100px">
                            <col width="">
                        </colgroup>
                        <tbody>
                            <tr>
                                <th class="text-right">작성자</th>
                                <td>
                                    <input type="text" class="form-control width120px" readonly id="mem_name" name="mem_name" value="${info.kor_name}">
                                    <input type="hidden" id="mem_no" name="mem_no" value="${info.mem_no}">
                                </td>		
                                <th class="text-right">작성일</th>
                                <td>
                                    <input type="text" class="form-control width120px" readonly id="doc_dt" name="doc_dt" value="${inputParam.s_current_dt}" dateformat="yyyy-MM-dd">
                                </td>							
                            </tr>
                            <tr>
                                <th class="text-right essential-item">신청자</th>
                                <td colspan="3">
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col width280px">
											<jsp:include page="/WEB-INF/jsp/common/searchMem.jsp">
		                                        <jsp:param name="execFuncName" value="setMemberOrgMapPanel"/>
		                                    </jsp:include>
                                        </div>
                                    </div>
                                    <input type="hidden" id="apply_mem_no" name="apply_mem_no">
                                </td>	
                            </tr>                             
                            <tr>
                                <th class="text-right">부서</th>
                                <td>
                                    <input type="text" class="form-control width120px" readonly id="org_name" name="org_name">
                                    <input type="hidden" id="org_code" name="org_code">
                                </td>		
                                <th class="text-right">직위</th>
                                <td>
                                    <input type="text" class="form-control width120px" readonly id="grade_name" name="grade_name">
                                    <input type="hidden" id="grade_cd" name="grade_cd">
                                    <input type="hidden" id="job_cd" name="job_cd">
                                </td>							
                            </tr>
                            <tr>
                                <th class="text-right essential-item">경조구분</th>
                                <td>
									<select class="form-control rb width120px" id="doc_money_type_cd" name="doc_money_type_cd" required="required" alt="경조구분" onChange="javascript:fnDocMoneyTypeSet(this.value);">
										<option value="">- 선택 -</option>
										<c:forEach items="${codeMap['DOC_MONEY_TYPE']}" var="item">
											<option value="${item.code_value}">${item.code_name}</option>
										</c:forEach>
									</select>
                                </td>		
                                <th class="text-right essential-item">경조대상</th>
                                <td>
									<select class="form-control rb width120px" id="doc_money_man_type_cd" name="doc_money_man_type_cd" required="required" alt="경조대상" onChange="javascript:fnGetMoneyAmt(this.value);">
										<option value="">- 선택 -</option>
<%-- 										<c:forEach items="${codeMap['DOC_MONEY_MAN_TYPE']}" var="item"> --%>
<%-- 											<option value="${item.code_value}">${item.code_name}</option> --%>
<%-- 										</c:forEach> --%>
									</select>
                                </td>							
                            </tr>
                            <tr>
                                <th class="text-right essential-item">경조일자</th>
                                <td>
                                    <div class="input-group width120px">
                                        <input type="text" class="form-control border-right-0 essential-bg width100px calDate" id="money_dt" name="money_dt" dateformat="yyyy-MM-dd" alt="경조일자" required="required" value="${inputParam.s_current_dt}">
                                    </div>
                                </td>
                                <th class="text-right essential-item">경조금액</th>
                                <td>
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col width130px">
                                            <input type="text" class="form-control text-right" readonly id="money_amt" name="money_amt" required="required" alt="경조금액" value="0" format="num">
                                        </div>
                                        <div class="col width16px">원</div>
                                        <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
<%--                                        <button type="button" class="btn btn-primary-gra mr10" name="fileAddBtn" id="fileAddBtn" onclick="javascript:editMoneyDef();">경조금 수정</button>--%>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right">비고</th>
                                <td colspan="3">
                                    <textarea class="form-control" placeholder="내용을 입력하세요." alt="비고" id="remark" name="remark" style="height: 70px;"></textarea>
                                </td>						
                            </tr>	
                            <tr>
                                <th class="text-right">첨부파일</th>
                                <td colspan="3">
									<div class="table-attfile doc_file_div" style="width:100%;">
										<div class="table-attfile" style="float:left">
										<button type="button" class="btn btn-primary-gra mr10" name="fileAddBtn" id="fileAddBtn" onclick="javascript:fnAddFile();">파일찾기</button>
										&nbsp;&nbsp;
										</div>
									</div>
                                </td>							
                            </tr>				
                        </tbody>
                    </table>				
<!-- /폼테이블 -->	
<!-- 하단 내용 -->                  
                    <div class="doc-com width750px">
                        <div class="text">
                            위와 같이 경조금지급을 신청 하오니 재가하여 주시기 바랍니다.<br>
                            ${inputParam.s_current_dt.substring(0,4)}년 ${inputParam.s_current_dt.substring(4,6)}월 ${inputParam.s_current_dt.substring(6,8)}일
                        </div>
                        <div class="detail-info">
                            부서 : <span id="org_name_text"></span><br>
                            성명 : <span id="reg_mem_name_text"></span>
                        </div> 
                    </div>			
<!-- /하단 내용 -->
					<div class="btn-group mt10 width750px">
						<div class="right">
                            <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
				</div>						
			</div>		
		</div>
<!-- /contents 전체 영역 -->	
</div>
<input type="hidden" id="doc_file_seq_1" name="doc_file_seq_1" value=""/>
<input type="hidden" id="doc_file_seq_2" name="doc_file_seq_2" value=""/>
<input type="hidden" id="doc_file_seq_3" name="doc_file_seq_3" value=""/>
<input type="hidden" id="doc_file_seq_4" name="doc_file_seq_4" value=""/>
<input type="hidden" id="doc_file_seq_5" name="doc_file_seq_5" value=""/>
</form>	
</body>
</html>