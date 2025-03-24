<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 인사 > 연봉관리 > null > 연봉 상세
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-04-09 14:09:44
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
	// 프린트하기 전 저장여부 체크
	var oldNorm = "${item.norm_salary_amt}";
	var oldSt = "${item.contract_st_dt}";
	var oldEd = "${item.contract_ed_dt}";
    var moduSendYn = "";
	
	$(document).ready(function() {
		if ("${item.file_seq}" != "" && "${item.file_seq}" != "0") {
			fnPrintFile("${item.file_seq}", "${item.file_name}");
		}

        if (${inputParam.modu_send_yn eq 'Y'} && ${empty item.modusign_id}) {
            sendModusignPanel();
        }
	});
	
	// 계약직 임금 계약서
	function goPrintAlbaWorker() {
		if (oldNorm != $M.getValue("norm_salary_amt") || oldSt != $M.getValue("contract_st_dt") || oldEd != $M.getValue("contract_ed_dt")) {
			alert("저장 후 다시 시도하세요.");
			return false;
		}
		
		var resiNo = "${item.resi_no}";
		
		var data = {
				"mem_name_yy" : $M.getValue("mem_name")+"("+resiNo.substring(0,2)+")"
				, "mem_name" : $M.getValue("mem_name")
				, "resi_no" : resiNo
				, "addr" : "${item.addr}"
				, "ipsa_dt" : "${item.ipsa_dt}"
				, "contract_st_dt" : $M.getValue("contract_st_dt")
				, "contract_ed_dt" : $M.getValue("contract_ed_dt")
				, "total_salary_amt" : $M.getValue("total_salary_amt")
				, "mon_salary_amt" : $M.getValue("mon_salary_amt")
				, "base_salary_amt" : $M.getValue("base_salary_amt")
				, "over_salary_amt" : $M.getValue("over_salary_amt")
				, "norm_salary_amt" : $M.getValue("norm_salary_amt")
				, "base_work_hour" : $M.getValue("base_work_hour")
				, "over_work_hour" : $M.getValue("over_work_hour")
				, "total_salary_hour" : $M.getValue("total_salary_hour")
			}
			var param = {
				"data" : data
			}
		
		openReportPanel('acnt/acnt0606p01_02.crf', param);
	}
	
	// 정규직 임금 계약서
	function goPrintFullTimeWorker() {
		if (oldNorm != $M.getValue("norm_salary_amt") || oldSt != $M.getValue("contract_st_dt") || oldEd != $M.getValue("contract_ed_dt")) {
			alert("저장 후 다시 시도하세요.");
			return false;
		}
		
		var resiNo = "${item.resi_no}";
		
		var data = {
				"mem_name" : $M.getValue("mem_name")+"("+resiNo.substring(0,2)+")"
				, "resi_no" : resiNo
				, "addr" : "${item.addr}"
				, "ipsa_dt" : "${item.ipsa_dt}"
				, "contract_st_dt" : $M.getValue("contract_st_dt")
				, "contract_ed_dt" : $M.getValue("contract_ed_dt")
				, "total_salary_amt" : $M.getValue("total_salary_amt")
				, "mon_salary_amt" : $M.getValue("mon_salary_amt")
				, "base_salary_amt" : $M.getValue("base_salary_amt")
				, "over_salary_amt" : $M.getValue("over_salary_amt")
				, "norm_salary_amt" : $M.getValue("norm_salary_amt")
				, "base_work_hour" : $M.getValue("base_work_hour")
				, "over_work_hour" : $M.getValue("over_work_hour")
				, "total_salary_hour" : $M.getValue("total_salary_hour")
			}
			var param = {
				"data" : data
			}
		
		openReportPanel('acnt/acnt0606p01_01.crf', param);
	}

    // 기본 계약서
    function goPrintBasicWorker() {
        if (oldNorm != $M.getValue("norm_salary_amt") || oldSt != $M.getValue("contract_st_dt") || oldEd != $M.getValue("contract_ed_dt")) {
            alert("저장 후 다시 시도하세요.");
            return false;
        }

        var resiNo = "${item.resi_no}";

        var data = {
            "mem_name_yy" : $M.getValue("mem_name")+"("+resiNo.substring(0,2)+")"
            , "mem_name" : $M.getValue("mem_name")
            , "resi_no" : resiNo
            , "addr" : "${item.addr}"
            , "ipsa_dt" : "${item.ipsa_dt}"
            , "contract_st_dt" : $M.getValue("contract_st_dt")
            , "contract_ed_dt" : $M.getValue("contract_ed_dt")
            , "total_salary_amt" : $M.getValue("total_salary_amt")
            , "mon_salary_amt" : $M.getValue("mon_salary_amt")
            , "base_salary_amt" : $M.getValue("base_salary_amt")
            , "over_salary_amt" : $M.getValue("over_salary_amt")
            , "norm_salary_amt" : $M.getValue("norm_salary_amt")
            , "base_work_hour" : $M.getValue("base_work_hour")
            , "over_work_hour" : $M.getValue("over_work_hour")
            , "total_salary_hour" : $M.getValue("total_salary_hour")
            , "regular_st_dt" : "${item.regular_st_dt}"
        }
        var param = {
            "data" : data
        }
        openReportPanel('acnt/acnt0606p01_03.crf', param);
    }
	
	function goSave() {
		var frm = document.main_form;
		
		if($M.checkRangeByFieldName("contract_st_dt", "contract_ed_dt", true) == false) {				
			return;
		}
		
		if($M.validation(frm) == false) {
     		return;
     	}
		
		
		$M.goNextPageAjaxSave(this_page, $M.toValueForm(frm), {method : 'POST'},
				function(result) {
			    	if(result.success) {
						alert("저장되었습니다.");
						location.reload();
					}
				}
			);
	}

	// 연봉총액
	function fnChangeTotalSalary() {
		
		// 연봉총액
		var totalAmt = $M.toNum($M.getValue("total_salary_amt"));
		
		// 총임금시간
		var totalHour = $M.toNum($M.getValue("total_salary_hour"));
		
		// 통상임금
		var norm = 0;
		if (totalHour != 0) {
			norm = Math.round(totalAmt/12/totalHour);
		}

		// 월급여
        var monSalaryAmt = Math.round(totalAmt/12);
		
		// 기본 시간
        var baseWorkHour = $M.toNum($M.getValue("base_work_hour"));
		
     	// 연장근로시간
		var overHour = $M.toNum($M.getValue("over_work_hour"));
     	
     	// 기본금 ( 209 시간 고정에서 기본시간에 곱해서 계산으로 변경 21.7.22 )
     	var basicAmt = norm*baseWorkHour;
     	
     	// 연장근로수당
     	var overAmt = 0;

     	// 연장근로시간이 0일 경우 기본급 = 월급여, 연장근로수당은 0
     	if (overHour == 0) {
     		basicAmt = monSalaryAmt;
     	} else {
     		overAmt = monSalaryAmt - basicAmt;
     	}
		
		// 연장근로수당 (2021.07.12 성현우 (기본급 + 연장근로수당이 월급여와 금액이 같아야한다는 유정은 팀장님 요청사항으로 수정))
		// var overAmt = norm*overHour;
        // overAmt = monSalaryAmt - basicAmt;
		
		var param = {
			base_salary_amt : basicAmt,
			mon_salary_amt : monSalaryAmt,
			over_salary_amt : overAmt,
			norm_salary_amt : norm
		}
		
		$M.setValue(param);
		
	}
	
	// 일근로시간
	function fnChangeDayWorkHour() {
		
		// 일근로시간
		var dayHour = $M.toNum($M.getValue("day_work_hour"));
		
		// 기본시간
		var basicHour = Math.round(((dayHour*6)/7)*(365/12));
		$M.setValue("base_work_hour", basicHour);
		
		// 연장근로시간
		var overHour = $M.toNum($M.getValue("over_work_hour"));
		
		// 총근로시간
		$M.setValue("total_salary_hour", basicHour+overHour);
		
		fnChangeTotalSalary();
	}
	
	// 주연장근로시간
	function fnChangeWeekOverHour() {
		
		// 주연장근로시간
		var weekOverHour = $M.toNum($M.getValue("week_over_hour"));
		
		// 연장근로시간
		var overWorkHour = Math.round(weekOverHour*1.5*4.34);
		$M.setValue("over_work_hour", overWorkHour);
		
		// 기본시간
		var basicHour = $M.toNum($M.getValue("base_work_hour"));
		
		// 총 임금시간
		$M.setValue("total_salary_hour", basicHour+overWorkHour);
		
		fnChangeTotalSalary();
	}
	
	// 닫기
	function fnClose() {
		window.close();
	}
	
	
	// 첨부파일 출력
	function fnPrintFile(fileSeq, fileName) {
		var str = ''; 
		str += '<div class="table-attfile-item bbs_file_1" style="float:left; display:block;">';
		str += '<a href="javascript:fileDownload(' + fileSeq + ');" style="color: blue; vertical-align: middle;">' + fileName + '</a>&nbsp;';
		str += '<input type="hidden" name="file_seq" value="' + fileSeq + '"/>';
		str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveFile(1, ' + fileSeq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
		str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
		str += '</div>';
		$('.bbs_file_div').append(str);
	}
	
	// 첨부파일 버튼 클릭
	function fnAddFile(){
		console.log($("input[name='file_seq']").size());
		if($("input[name='file_seq']").size() >= 1) {
			alert("파일은 1개만 첨부하실 수 있습니다.");
			return false;
		}
		openFileUploadPanel('setFileInfo', 'upload_type=SAL&file_type=both&max_size=2048');
	}
	
	function setFileInfo(result) {
		fnPrintFile(result.file_seq, result.file_name);
	}
	
	// 첨부파일 삭제
	function fnRemoveFile(fileIndex, fileSeq) {
		var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
		if (result) {
			$(".bbs_file_" + fileIndex).remove();
		} else {
			return false;
		}
	}

    // 모두싸인 요청 (저장 후 진행)
    function sendModusignPanel() {
        var params = {
            "target_type_cm" : "M",
            "mem_name" : $M.getValue("mem_name"),
            "hp_no" : $M.getValue("hp_no"),
            "email" : $M.getValue("email"),
            "confirm_msg" : "저장된 내용으로 싸인 문서가 발송됩니다.\n내용 변경시 저장 및 싸인취소 후 다시 재진행하셔야 합니다.",
        }
        openSendModusignPanel('sendModusignTemplate', $M.toGetParam(params));
    }

    function sendModusignTemplate(data) {
        var param = {
            "mem_name" : data.mem_name,
            "modusign_doc_cd" : 'SALARY_DOC_' + $M.getValue("employ_type_rc"),
            "modusign_send_cd" : data.modusign_send_cd,
            "send_hp_no" : data.modusign_send_value,
            "hp_no" : data.modusign_send_value,
            "send_email" : data.modusign_send_value,
            "modusign_cust_app_yn" : 'N',
            "mem_year_salary_no" : $M.getValue("mem_year_salary_no"),
            "modu_modify_yn" : $M.getValue("modu_modify_yn") == ""? "N":$M.getValue("modu_modify_yn")
        };
        $M.goNextPageAjax("/modu/request_document", $M.toGetParam(param), {method : 'POST'},
            function(result) {
                if(result.success) {
                    location.reload();
                }
            }
        );
    }

    function sendModusignCancel() {
        var msg = "싸인을 취소하시겠습니까?";
        var param = {
            "modusign_id" : "${item.modusign_id}",
        };
        $M.goNextPageAjaxMsg(msg, "/modu/request/cancel", $M.toGetParam(param), {method : 'POST'},
            function(result) {
                if(result.success) {
                    location.reload();
                }
            }
        );
    }

    function fnModusignModify() {
        var frm = document.main_form;

        $("#_sendModusignPanel").show();
        $("#_sendContactModusignPanel").show();
        $("#_fnModusignModify").hide();
        $("#_file_name").hide();
        $M.setValue(frm, "modu_modify_yn", "Y");
    }
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" name="mem_year_salary_no" id="mem_year_salary_no" value="${item.mem_year_salary_no}">
<input type="hidden" name="modu_modify_yn" value="${modusignMap.modu_modify_yn}">
<div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
			<div class="title-wrap">
				<div class="left">
					<h4 class="primary">연봉상세</h4>		
                </div>
                <div class="right">
                    <button type="button" class="btn btn-md btn-rounded btn-outline-primary" onclick="goPrintBasicWorker()"><i class="material-iconsprint text-primary"></i> 기본 계약서 출력</button>
                    <button type="button" class="btn btn-md btn-rounded btn-outline-primary" onclick="goPrintAlbaWorker()"><i class="material-iconsprint text-primary"></i> 계약직 임금 계약서 출력</button>
                    <button type="button" class="btn btn-md btn-rounded btn-outline-primary" onclick="goPrintFullTimeWorker()"><i class="material-iconsprint text-primary"></i> 정규직 임금 계약서 출력</button>
                </div>
            </div>	

            <table class="table-border mt10">
				<colgroup>
					<col width="120px">
					<col width="">
					<col width="120px">
					<col width="">
				</colgroup>
				<tbody>
					<tr>
						<th class="text-right">직원명</th>
						<td>
							<input type="text" class="form-control width120px" readonly="readonly" value="${item.mem_name}" name="mem_name">
						</td>	
						<th class="text-right">부서</th>
						<td>
							<input type="text" class="form-control width120px" readonly="readonly" value="${item.org_name}">
						</td>
                    </tr>
                    <tr>
						<th class="text-right">연락처</th>
						<td>
							<input type="text" class="form-control width120px" readonly="readonly" value="${item.hp_no}" id="hp_no" name="hp_no" format="phone">
						</td>	
						<th class="text-right">직위</th>
						<td>
							<input type="text" class="form-control width120px" readonly="readonly" value="${item.grade_name}">
							<input type="hidden" class="form-control width120px" id="grade_cd" value="${item.grade_cd}">
							<input type="hidden" class="form-control width120px" id="job_cd" value="${item.job_cd}">
						</td>
                    </tr>
                    <tr>
                        <th class="text-right">계약구분</th>
                        <td colspan="3">
                            <select class="form-control width100px" id="employ_type_rc" name="employ_type_rc">
                                <option value="R" ${item.employ_type_rc eq 'R'? 'selected="selected"' : ''}>정규직</option>
                                <option value="C" ${item.employ_type_rc eq 'C'? 'selected="selected"' : ''}>계약직</option>
                            </select>
                        </td>
                    </tr>
				</tbody>
			</table>            
<!-- 계약기간 -->		
            <div class="title-wrap mt10">
                <h4>계약기간</h4>            
            </div>		
            <table class="table-border mt5">
                <colgroup>
                    <col width="120px">
                    <col width="">
                </colgroup>
                <tbody>
                    <tr>
                        <th class="text-right rs">계약기간</th>
                        <td>
                            <div class="form-row inline-pd widthfix">
								<div class="col width110px">
									<div class="input-group">
										<input type="text" class="form-control border-right-0 calDate rb" id="contract_st_dt" name="contract_st_dt" value="${item.contract_st_dt }" dateformat="yyyy-MM-dd" alt="계약시작일" required="required">
									</div>
								</div>
								<div class="col width16px text-center">~</div>
								<div class="col width120px">
									<div class="input-group">
										<input type="text" class="form-control border-right-0 calDate rb" id="contract_ed_dt" name="contract_ed_dt" value="${item.contract_ed_dt }" dateformat="yyyy-MM-dd" alt="계약종료일" required="required">
									</div>
								</div>
							</div>
                        </td>	
                    </tr>
                </tbody>
            </table>
<!-- 계약기간 -->	
<!-- 근로시간 -->	
            <div class="title-wrap mt10">
                <h4>근로시간</h4>            
            </div>			
			<table class="table-border mt5">
				<colgroup>
					<col width="120px">
					<col width="">
					<col width="120px">
					<col width="">
				</colgroup>
				<tbody>
					<tr>
						<th class="text-right rs">일근로시간</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width80px">
									<input type="text" class="form-control text-right rb" id="day_work_hour" name="day_work_hour" value="${item.day_work_hour}" format="num" onblur="javascript:fnChangeDayWorkHour()" alt="일근로시간" required="required">
								</div>
								<div class="col width33px">hr</div>
							</div>
						</td>	
						<th class="text-right">주 연장근로시간</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width80px">
									<input type="text" class="form-control text-right rb" id="week_over_hour" name="week_over_hour" value="${item.week_over_hour}" format="num" onblur="javascript:fnChangeWeekOverHour()" alt="주 연장근로시간" required="required">
								</div>
								<div class="col width33px">hr</div>
							</div>
						</td>	
                    </tr>
                    <tr>
						<th class="text-right">기본시간</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width80px">
									<input type="text" class="form-control text-right" readonly="readonly" id="base_work_hour" name="base_work_hour" value="${item.base_work_hour}" format="num">
								</div>
								<div class="col width33px">hr</div>
							</div>
						</td>	
						<th class="text-right">연장근로시간</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width80px">
									<input type="text" class="form-control text-right" readonly="readonly" id="over_work_hour" name="over_work_hour" value="${item.over_work_hour }" format="num">
								</div>
								<div class="col width33px">hr</div>
							</div>
						</td>	
                    </tr>
                    <tr>
						<th class="text-right">총 임금시간</th>
						<td colspan="3">
							<div class="form-row inline-pd widthfix">
								<div class="col width80px">
									<input type="text" class="form-control text-right" readonly="readonly" id="total_salary_hour" name="total_salary_hour" value="${item.total_salary_hour }" format="num">
								</div>
								<div class="col width33px">hr</div>
							</div>
						</td>
					</tr>					
				</tbody>
			</table>
<!-- 근로시간 -->	
<!-- 기본연봉 -->	
            <div class="title-wrap mt10">
                <h4>기본연봉</h4>            
            </div>			
            <table class="table-border mt5">
                <colgroup>
                    <col width="120px">
                    <col width="">
                    <col width="120px">
                    <col width="">
                </colgroup>
                <tbody>
                    <tr>
                        <th class="text-right rs">연봉총액</th>
                        <td colspan="3">
                            <div class="form-row inline-pd widthfix">
                                <div class="col width130px">
                                    <input type="text" class="form-control text-right rb" id="total_salary_amt" name="total_salary_amt" value="${item.total_salary_amt }" format="num" onblur="javascript:fnChangeTotalSalary()" alt="연봉총액" required="required">
                                </div>
                                <div class="col width16px">원</div>
                            </div>
                        </td>	
                    </tr>
                    <tr>
                        <th class="text-right">기본급</th>
                        <td>
                            <div class="form-row inline-pd widthfix">
                                <div class="col width130px">
                                    <input type="text" class="form-control text-right" readonly="readonly" id="base_salary_amt" name="base_salary_amt" value="${item.base_salary_amt }" format="num">
                                </div>
                                <div class="col width16px">원</div>
                            </div>
                        </td>	
                        <th class="text-right">월급여</th>
                        <td>
                            <div class="form-row inline-pd widthfix">
                                <div class="col width130px">
                                    <input type="text" class="form-control text-right" readonly="readonly" id="mon_salary_amt" name="mon_salary_amt" value="${item.mon_salary_amt}" format="num">
                                </div>
                                <div class="col width16px">원</div>
                            </div>
                        </td>	
                    </tr>
                    <tr>
                        <th class="text-right">연장근로수당</th>
                        <td>
                            <div class="form-row inline-pd widthfix">
                                <div class="col width130px">
                                    <input type="text" class="form-control text-right" readonly="readonly" id="over_salary_amt" name="over_salary_amt" value="${item.over_salary_amt }" format="num">
                                </div>
                                <div class="col width16px">원</div>
                            </div>
                        </td>	
                        <th class="text-right">통상임금</th>
                        <td>
                            <div class="form-row inline-pd widthfix">
                                <div class="col width130px">
                                    <input type="text" class="form-control text-right" readonly="readonly" id="norm_salary_amt" name="norm_salary_amt" value="${item.norm_salary_amt }" format="num">
                                </div>
                                <div class="col width16px">원</div>
                            </div>
                        </td>	
                    </tr>					
                </tbody>
            </table>
<!-- 기본연봉 -->	
<!-- 고과반영 -->	
            <div class="title-wrap mt10">
                <h4>고과반영</h4>            
            </div>			
            <table class="table-border mt5">
                <colgroup>
                    <col width="120px">
                    <col width="">
                    <col width="120px">
                    <col width="">
                </colgroup>
                <tbody>
                    <tr>
                        <th class="text-right">능력레벨</th>
                        <td>
                            <div class="form-row inline-pd widthfix">
                                <div class="col width130px">
                                    <input type="text" class="form-control text-right" readonly="readonly" id="ability_amt" name="ability_amt" value="${item.ability_amt }" format="num">
                                </div>
                                <div class="col width16px">원</div>
                            </div>
                        </td>
                        <th class="text-right">직책수당</th>
                        <td>
                            <div class="form-row inline-pd widthfix">
                                <div class="col width130px">
                                    <input type="text" class="form-control text-right" readonly="readonly" id="job_amt" name="job_amt" value="${item.job_amt}" format="num">
                                </div>
                                <div class="col width16px">원</div>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">언어수당</th>
                        <td>
                            <div class="form-row inline-pd widthfix">
                                <div class="col width130px">
                                    <input type="text" class="form-control text-right" readonly="readonly" id="lang_amt" name="lang_amt" value="${item.lang_amt }" format="num">
                                </div>
                                <div class="col width16px">원</div>
                            </div>
                        </td>
                        <th class="text-right">조정</th>
                        <td>
                            <div class="form-row inline-pd widthfix">
                                <div class="col width130px">
                                    <input type="text" class="form-control text-right" readonly="readonly" id="adjust_salary_amt" name="adjust_salary_amt" value="${item.adjust_salary_amt }" format="num">
                                </div>
                                <div class="col width16px">원</div>
                            </div>
                        </td>
                    </tr>	
                </tbody>
            </table>
<!-- 고과반영 -->	

<!-- 계약서업로드 -->				
			<table class="table-border mt10">
				<colgroup>
					<col width="120px">
					<col width="">
				</colgroup>
				<tbody>
					<tr>
                        <th class="text-right">전자계약</th>
                        <td>
                            <div class="form-row inline-pd widthfix">
                                <div class="col-auto">
                                    <button type="button" class="btn btn-primary-gra mr5"  onclick="javascript:sendModusignPanel()" id="_sendModusignPanel"
                                            <c:if test="${!(empty item.modusign_id and page.add.MODUSIGN_YN eq 'Y')}">style="display:none;"</c:if>>발송</button>
                                    <c:if test="${not empty item.modusign_id and page.add.MODUSIGN_YN eq 'Y' and modusignMap.sign_proc_yn eq 'Y'}">
                                        <button type="button" class="btn btn-primary-gra"  onclick="javascript:void();" disabled>${modusignMap.modusign_status_label}</button>
                                        <button type="button" class="btn btn-primary-gra ml5" onclick="javascript:sendModusignCancel()">싸인취소</button>
                                    </c:if>
                                    <c:if test="${modusignMap.file_seq ne 0}">
                                        <a href="javascript:fileDownload('${modusignMap.file_seq}');" style="color: blue; vertical-align: middle;" id="_file_name">${modusignMap.file_name}</a>
                                        <c:if test="${page.add.MODUSIGN_YN eq 'Y' and modusignMap.modu_modify_yn eq 'N'}">
                                            <button type="button" class="btn btn-primary-gra ml5" onclick="javascript:fnModusignModify()" id="_fnModusignModify">수정</button>
                                        </c:if>
                                    </c:if>
                                </div>
                                <c:if test="${modusignMap.modu_modify_yn eq 'Y'}">
                                    <div class="col-auto">(수정중)</div>
                                </c:if>
                            </div>
                        </td>
                    </tr>
                    <tr>
						<th class="text-right">종이계약서</th>
						<td>
							<div class="table-attfile bbs_file_div" style="width:100%;">
								<div class="table-attfile" style="float:left">
								<button type="button" class="btn btn-primary-gra check-dis" onclick="javascript:fnAddFile();">파일찾기</button>
								&nbsp;&nbsp;
								</div>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">비고</th>
						<td>
							<textarea class="form-control" style="height: 100px;" placeholder="내용을 입력하세요" id="remark" name="remark" maxlength="100">${item.remark}</textarea>
						</td>
					</tr>						
				</tbody>
			</table>
<!-- /계약서업로드 -->
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt10">						
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
</form>
</body>
</html>