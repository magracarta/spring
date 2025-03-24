<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 인사 > 징계관리 > 징계등록 > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-04-29 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

	var memPntCutJson = JSON.parse('${codeMapJsonObj['MEM_PNT_CUT']}');  // 감봉구분코드 (1~6)
	
	// 저장
	function goSave() {
		var frm = document.main_form;
		
		if ($M.getValue("mem_no") == "") {
			alert("직원을 선택해 주세요.");
			return;
		}
		
		// validation check
		if($M.validation(document.main_form) == false) {
			return;
		};
		
		$M.goNextPageAjaxSave(this_page + "/save", $M.toValueForm(frm) , {method : 'POST'},
			function(result) {
	    		if(result.success) {
	    			$M.goNextPage("/acnt/acnt0604");
				}
			}
		);		
	}
	
	// 목록
	function fnList() {
		history.back();
	}
	
	// 직원조회
	function setMemberOrgMapPanel(data) {
		$M.setValue("mem_name", data.mem_name);
		$M.setValue("mem_no", data.mem_no);
		$M.setValue("org_name", data.org_name);
		$M.setValue("grade_cd", data.grade_cd);
		$M.setValue("grade_name", data.grade_name);
		$M.setValue("job_cd", data.job_cd);
		$M.setValue("job_name", data.job_name);
	}
	
	// 징계구분이 바뀔때마다 html form 변경
	function fnToggleRows(val) {
		$M.clearValue({field:["mem_pnt_cut_cd", "down_cut_amt", "down_grade_cd", "stop_st_dt", "stop_ed_dt"]});
		
		switch(val) {
			// 감봉
			case "03" : $(".down_cut").removeClass("dpn");
						$(".down_grade").addClass("dpn");
						$(".stop_dt").addClass("dpn");
						break;
			// 강직
			case "04" : $(".down_grade").removeClass("dpn");
						$(".down_cut").addClass("dpn");
						$(".stop_dt").addClass("dpn");
						break;
			// 정직
			case "05" : $(".stop_dt").removeClass("dpn");
						$(".down_cut").addClass("dpn");
						$(".down_grade").addClass("dpn");
						break;
			// 훈계, 징계해고
			default : $(".stop_dt").addClass("dpn");
					  $(".down_cut").addClass("dpn");
					  $(".down_grade").addClass("dpn");
					  break;
		}
	}
	
	// 징계구분 - 감봉 선택시 기존 코드값 세팅
	function fnChangeDownCutAmt(val) {
		var downAmt = 0;  // 감봉액
		
		for (var i = 0; i < memPntCutJson.length; i++) {
			if (val == memPntCutJson[i].code_value) {
				downAmt = memPntCutJson[i].code_v1;  // 코드값에 맞는 감봉액 세팅
			}
		} 
		
		$M.setValue("down_cut_amt_text", $M.setComma(parseInt(downAmt + "0000") * -1));
		$M.setValue("down_cut_amt", parseInt(downAmt + "0000"));
	}
	
	// 금액 직접 입력시 값 세팅
	function fnChangeAmt(val) {
		$M.setValue("down_cut_amt_text", $M.setComma(parseInt(val) * -1));
		$M.setValue("down_cut_amt", parseInt(val));
	}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 상세페이지 타이틀 -->
				<div class="main-title detail">
					<div class="detail-left">
						<button type="button" class="btn btn-outline-light" onclick="javascript:fnList();"><i class="material-iconskeyboard_backspace text-default"></i></button>
						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
					</div>
				</div>
<!-- /상세페이지 타이틀 -->
				<div class="contents">
<!-- 상단 폼테이블 -->					
					<div>
						<table class="table-border width750px">
							<colgroup>
								<col width="100px">
                                <col width="">
                                <col width="100px">
                                <col width="">
							</colgroup>
							<tbody>
								<tr>
									<th class="text-right">작성일</th>
									<td>
										<input type="text" class="form-control width120px" id="reg_date" name="reg_date" readonly value="${inputParam.s_current_dt}" dateFormat="yyyy-MM-dd">
									</td>		
									<th class="text-right essential-item">직원명</th>
									<td>
                                        <div class="form-row inline-pd widthfix">
                                            <div class="col width240px">
<%--                                           		<jsp:include page="/WEB-INF/jsp/common/searchMem.jsp"> --%>
<%-- 						                     		<jsp:param name="required_field" value="s_web_id"/> --%>
<%-- 						                     	</jsp:include> --%>
												<jsp:include page="/WEB-INF/jsp/common/searchMem.jsp">
			                                        <jsp:param name="execFuncName" value="setMemberOrgMapPanel"/>
			                                    </jsp:include>
<!--                                                     <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openMemberOrgPanel('setOrgMapPanel','N');"><i class="material-iconssearch"></i></button> -->
                                            </div>
<!--                                             <div class="col width100px"> -->
<!--                                                 <input type="text" class="form-control" readonly placeholder="성명" id="mem_name" name="mem_name"> -->
<!--                                                 <input type="hidden" class="form-control" id="mem_no" name="mem_no"> -->
<!--                                             </div> -->
                                        </div>
                                    </td>							
                                </tr>
                                <tr>
									<th class="text-right">부서</th>
									<td>
										<input type="text" class="form-control width120px" readonly id="org_name" name="org_name">
									</td>		
									<th class="text-right">직위</th>
									<td>
                                        <input type="text" class="form-control width120px" readonly id="grade_name" name="grade_name">
                                        <input type="hidden" id="grade_cd" name="grade_cd">
                                        <input type="hidden" id="job_cd" name="job_cd">
                                    </td>							
                                </tr>						
							</tbody>
						</table>
					</div>					
<!-- /상단 폼테이블 -->	
<!-- 하단 폼테이블 -->					
                    <div>
                        <div class="title-wrap mt10">
                            <h4>징계</h4>
                        </div>
                        <table class="table-border width750px">
                            <colgroup>
                                <col width="100px">
                                <col width="">
                                <col width="100px">
                                <col width="">
                            </colgroup>
                            <tbody>
                                <tr>
                                    <th class="text-right essential-item">징계구분</th>
                                    <td>
										<select class="form-control width100px essential-bg" id="mem_penalty_cd" name="mem_penalty_cd" alt="징계구분" required="required" onchange="javascipt:fnToggleRows(this.value)">
											<option value="">- 선택 -</option>
											<c:forEach items="${codeMap['MEM_PENALTY']}" var="item">
												<c:if test="${item.code_value != '02'}">
													<option value="${item.code_value}">${item.code_name}</option>
												</c:if>
											</c:forEach>
										</select>
                                    </td>		
                                    <th class="text-right essential-item">반영일자</th>
                                    <td>
                                        <div class="input-group width130px">
                                            <input type="text" class="form-control border-right-0 width100px calDate essential-bg" id="apply_dt" name="apply_dt" dateformat="yyyy-MM-dd" alt="반영일자" required="required">
                                        </div>
                                    </td>							
                                </tr>
                                <tr>
                                    <th class="text-right down_cut dpn">감봉등급</th>
                                    <td class="down_cut dpn">
										<select class="form-control width100px" id="mem_pnt_cut_cd" name="mem_pnt_cut_cd" onchange="javascipt:fnChangeDownCutAmt(this.value);">
											<option value="">- 선택 -</option>
											<c:forEach items="${codeMap['MEM_PNT_CUT']}" var="item">
												<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach>
										</select>
                                    </td>		
                                    <th class="text-right down_cut dpn">감봉액</th>
                                    <td class="down_cut dpn">
                                        <div class="form-row inline-pd widthfix">
                                            <div class="col width120px">
                                                <input type="text" class="form-control text-right" id="down_cut_amt_text" name="down_cut_amt_text" onchange="javascipt:fnChangeAmt(this.value);" format="num">
                                                <input type="hidden" id="down_cut_amt" name="down_cut_amt">
                                            </div>
                                            <div class="col width16px">원</div>
                                        </div>
                                    </td>							
                                </tr>
                                <tr>
                                    <th class="text-right down_grade dpn">강등처리</th>
                                    <td colspan="3" class="down_grade dpn">
										<select class="form-control width80px" id="down_grade_cd" name="down_grade_cd">
											<option value="">- 선택 -</option>
											<c:forEach items="${codeMap['GRADE']}" var="item">
												<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach>
										</select>
                                    </td>							
                                </tr>
                                <tr>
                                    <th class="text-right stop_dt dpn">정직기간</th>
                                    <td colspan="3" class="stop_dt dpn">
                                        <div class="row widthfix">
                                            <div class="col width120px">
                                                <div class="input-group">
                                                	<input type="text" class="form-control border-right-0 width100px calDate" id="stop_st_dt" name="stop_st_dt" dateformat="yyyy-MM-dd" alt="정직시작일">
                                                </div>
                                            </div>
                                            <div class="col width16px">~</div>
                                            <div class="col width120px">
                                                <div class="input-group">
                                                	<input type="text" class="form-control border-right-0 width100px calDate" id="stop_ed_dt" name="stop_ed_dt" dateformat="yyyy-MM-dd" alt="정직종료일">
                                                </div>
                                            </div>
                                        </div>
                                    </td>								
                                </tr>	
                                <tr>
                                    <th class="text-right">비고</th>
                                    <td colspan="3">
                                        <textarea class="form-control" placeholder="내용을 입력하세요." style="height: 200px;" id="remark" name="remark"></textarea>
                                    </td>
                                </tr>				
                            </tbody>
                        </table>
                    </div>					
<!-- /하단 폼테이블 -->
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
</form>	
</body>
</html>