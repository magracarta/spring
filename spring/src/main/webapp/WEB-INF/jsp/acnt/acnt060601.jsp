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
	
	$(document).ready(function() {
		if ("${item.file_seq}" != "" && "${item.file_seq}" != "0") {
			fnPrintFile("${item.file_seq}", "${item.file_name}");
		}
	});
	
	// 직원조회
	function setMemberOrgMapPanel(data) {
		$M.setValue("mem_name", data.mem_name);
		$M.setValue("mem_no", data.mem_no);
		$M.setValue("org_name", data.org_name);
		$M.setValue("org_code", data.org_code);
		$M.setValue("grade_cd", data.grade_cd);
		$M.setValue("grade_name", data.grade_name);
		$M.setValue("job_cd", data.job_cd);
		$M.setValue("job_name", data.job_name);
		$M.setValue("hp_no", data.hp_no_real);

		// 이전 계약일자 조회 후 세팅
		var param = {
			"mem_no": $M.getValue("mem_no")
		}
		$M.goNextPageAjax(this_page+"/contractDt", $M.toGetParam(param), {method : 'GET'},
				function(result) {
					if(result.success) {
						$M.setValue("contract_st_dt", result.contract_st_dt);
						$M.setValue("contract_ed_dt", result.contract_ed_dt);
					}
				}
		);
	}
	
	function goSave() {
		var frm = document.main_form;
		
		if($M.checkRangeByFieldName("contract_st_dt", "contract_ed_dt", true) == false) {				
			return;
		}
		
		if ($M.getValue("___mem_name") == "") {
			alert("직원명은 필수입니다.");
			$("#___mem_name").focus();
			return false;
		}
		
		if($M.validation(frm) == false) {
     		return;
     	}
		
		$M.goNextPageAjaxSave(this_page+"/save", $M.toValueForm(frm), {method : 'POST'},
				function(result) {
			    	if(result.success) {
						$M.setValue("mem_year_salary_no", result.mem_year_salary_no);
						fnList("Y");
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
	
	// 뒤로가기
	function fnList(moduSendYn) {
		if (moduSendYn == "Y") {
			var param = {
				"mem_year_salary_no" : $M.getValue("mem_year_salary_no"),
				"modu_send_yn" : "Y"
			};
			var poppupOption = "";
			$M.goNextPage('/acnt/acnt0606p01', $M.toGetParam(param), {popupStatus : poppupOption});
		}
		$M.goNextPage("/acnt/acnt0606");
	}
	
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="mem_no" name="mem_no">

<div class="layout-box">
<!-- contents 전체 영역 -->
<div class="content-wrap" style="max-width: 60%">
			<div class="content-box">
<!-- 상세페이지 타이틀 -->
				<div class="main-title detail">
					<div class="detail-left">
						<button type="button" class="btn btn-outline-light" onclick="fnList()"><i class="material-iconskeyboard_backspace text-default"></i></button>
						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
					</div>
				</div>
<!-- /상세페이지 타이틀 -->
				<div class="contents">
<!-- 기본정보 -->					
					<div>
						<div class="title-wrap">
							<h4>기본정보</h4>									
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
						<th class="text-right rs">직원명</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width240px">
									<jsp:include page="/WEB-INF/jsp/common/searchMem.jsp">
	                            		<jsp:param name="execFuncName" value="setMemberOrgMapPanel"/>
	                        		</jsp:include>
	                            </div>
	                        </div>
						</td>	
						<th class="text-right">부서</th>
						<td>
							<input type="text" class="form-control width120px" id="org_name" name="org_name"  readonly="readonly" value="${item.org_name}">
							<input type="hidden" id="org_code" name="org_code">
						</td>
                    </tr>
                    <tr>
						<th class="text-right">연락처</th>
						<td>
							<input type="text" class="form-control width120px" readonly="readonly" value="${item.hp_no}" id="hp_no" name="hp_no" format="phone">
						</td>	
						<th class="text-right">직위</th>
						<td>
							<input type="text" class="form-control width120px" readonly="readonly" id="grade_name" name="grade_name" value="${item.grade_name}">
							<input type="hidden" class="form-control width120px" id="grade_cd" value="${item.grade_cd}">
							<input type="hidden" class="form-control width120px" id="job_cd" value="${item.job_cd}">
						</td>
					</tr>
					<tr>
						<th class="text-right">계약구분</th>
						<td colspan="3">
							<select class="form-control width100px" id="employ_type_rc" name="employ_type_rc">
								<option value="R" selected="selected">정규직</option>
								<option value="C">계약직</option>
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
            <!-- 계약서업로드 -->				
			<table class="table-border mt10">
				<colgroup>
					<col width="120px">
					<col width="">
				</colgroup>
				<tbody>
					<tr>
						<th class="text-right">계약서업로드</th>
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
					</div>					
<!-- /기본정보 -->	
					<div class="btn-group mt10">
						<div class="right">
							<button type="button" class="btn btn-info" onclick="javascript:goSave()">저장</button>
							<button type="button" class="btn btn-info" onclick="javascript:fnList()">목록</button>
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