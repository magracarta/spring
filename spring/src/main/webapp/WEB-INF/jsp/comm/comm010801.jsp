<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 사용자관리 > null > 사용자상세
-- 작성자 : 강명지
-- 최초 작성일 : 2020-01-20 13:11:19
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var defaultImg ="/static/img/icon-user.png";
	
		$(document).ready(function() {

			$("#retireField").children("button").addClass('btn-cancel');
			$("#retireField").children("button").attr('disabled', true);
						
			//퇴직여부 확인		
			$('#work_status_cd').change(function() {
				if($M.getValue("work_status_cd")=='04') {
					fnRetireYn(true);
				}
				else {
					fnRetireYn(false);
				}
			});

			$("#fileRemoveBtn").on("click",function(e){
				fnRemoveFile();
			});
			
			
			
			$("#web_id").on("propertychange change keyup paste input", function() {
				if ($M.getValue("lastchk_web_id") == this.value ) {
					$M.setValue("web_id_chk","Y");
					$('#btn_web_id_chk').prop( 'disabled', true );
				}else {
					$M.setValue("web_id_chk","N");
					$('#btn_web_id_chk').prop( 'disabled', false );
				}
			});	
			
			$('#hp_no').on("propertychange change keyup paste input", function() {
				
				if ($M.getValue("lastchk_hp_no") == this.value) {
					$M.setValue("hp_no_chk","Y");					
					$('#btn_hp_no_chk').prop( 'disabled', true );

				}else {
					$M.setValue("hp_no_chk","N");
					$('#btn_hp_no_chk').prop( 'disabled', false );
				}				
			});
			
						
			$('#resi_no1,#resi_no2').on("propertychange change keyup paste input", function() {

				var resi_no = $M.getValue("resi_no1")+$M.getValue("resi_no2");
				$M.setValue("resi_no",resi_no);
				
				if ($M.getValue("lastchk_resi_no")  == $M.getValue("resi_no")) {
					$M.setValue("resi_no_chk","Y");
					$('#btn_resi_no_chk').prop( 'disabled', true );
				}else {
					$M.setValue("resi_no_chk","N");
					$('#btn_resi_no_chk').prop( 'disabled', false );
				}								
			});
						
		});
			
		function fnRetireYn(flag)
		{
			
			if(flag) {
				$("#retire_dt").attr("readonly", false);
				$("#cert_company_opinion").attr("readonly", false);
				$("#retire_dt").attr("required", true);
				$("#cert_company_opinion").attr("required", true);									
				$("#retireField").children("button").attr('disabled', false);
								
			}
			else {
				$("#retire_dt").attr("readonly", true);
				$("#cert_company_opinion").attr("readonly", true);
				$M.setValue("retire_dt", "");
				$M.setValue("cert_company_opinion", "");
				$("#retire_dt").attr("required", false);
				$("#cert_company_opinion").attr("required", false);						
				$("#retireField").children("button").attr('disabled', true);
			}		
		}			
		
		function fnJusoBiz(data) {
			$M.setValue("home_post_no", data.zipNo);
			$M.setValue("home_addr1", data.roadAddrPart1);
			$M.setValue("home_addr2", data.addrDetail);
		}
		
		
		function fnRemoveFile(){
			$("#profile").remove();
			$('#profileImage').attr('src', defaultImg).width(150);
			$M.setValue('pic_file_seq','0');			
		}

		function fnDelBtnShow(){	
			if($('#profileImage').attr('src') != defaultImg ) {
				$(".profilephoto-delete").show();
			}
		}
		
		function fnDelBtnHide(){
			$(".profilephoto-delete").hide();
		}
		
		
		function goSearchFile() {
			var param = {
				upload_type	: 'MEM',
				file_type : 'img',
				max_size : 1024
			};
			openFileUploadPanel("fnSetImage", $M.toGetParam(param));
		}
		

	
		// 팝업창에서 받아온 값
		function fnSetImage(result) {
			if (result != null && result.file_seq != null) {
				$M.setValue("pic_file_seq",result.file_seq);				
			 	$('#profileImage').attr('src', '/file/'+result.file_seq + '').width(188);			  		
			}
		}
		
		
		
		function goWebIdCheck() {
			if($M.getValue("web_id") == '' || $M.getValue("web_id") == undefined) {
				alert("아이디를 입력해주세요"); 
				return;	
			}				
			if ($M.getValue("web_id_chk") != "Y" ) {

				$M.goNextPageAjax(this_page+"/webIdCheck/"+$M.getValue("web_id"), '', {method : 'get'},
					function(result) {
			    		if(result.success) {
			    			$M.setValue("lastchk_web_id", $M.getValue("web_id") );
			    			$M.setValue("web_id_chk","Y");
			    			$('#btn_web_id_chk').prop( 'disabled', true );
			    			    			
						}else{
							$M.setValue("web_id_chk","N");
							$('#btn_web_id_chk').prop( 'disabled', false );

			    		}
					}
				);
			}
			else{				
				alert("사용가능한 아이디 입니다");
			}
		}
		
		function goResiNoCheck() {
			if($M.getValue("resi_no1") == '' || $M.getValue("resi_no1") == undefined || $M.getValue("resi_no2") == '' || $M.getValue("resi_no2") == undefined) {
				alert("주민등록번호를 확인해주세요"); 
				return;	
			} 
			var resi_no =  $M.getValue("resi_no1") + $M.getValue("resi_no2");
			var param = {
	 			"resi_no" 	: resi_no,
			};

			if ($M.getValue("resi_no_chk") != "Y" ) {
			
				$M.goNextPageAjax(this_page+"/resiNoCheck/", $M.toGetParam(param), {method : 'post'},
					function(result) {
			    		if(result.success) {	    		
			    			$M.setValue("lastchk_resi_no",resi_no);
			    			$M.setValue("resi_no_chk","Y");
			    			$("#btn_resi_no_chk").prop("disabled", true);
						}
			    		else{
			    			$M.setValue("resi_no_chk","N");
			    			$("#btn_resi_no_chk").prop("disabled", false);
			    		}
					}
				);			
			}
			else{
				alert("사용가능한 주민번호 입니다");
			}
		}
				
		function goHpNoCheck() {
			if($M.getValue("hp_no") == '' || $M.getValue("hp_no") == undefined) {
				alert("핸드폰 번호를 입력해주세요"); 
				return;	
			}

			if ($M.getValue("hp_no_chk") != "Y" ) {	
				$M.goNextPageAjax(this_page+"/hpNoCheck/"+$M.getValue("hp_no"), '', {method : 'get'},
					function(result) {
			    		if(result.success) {
			    			$M.setValue("hp_no_chk","Y");
			    			$M.setValue("lastchk_hp_no",$M.getValue("hp_no"));
			    			$("#btn_hp_no_chk").prop("disabled", true);
						}else{
							$M.setValue("hp_no_chk","N");
							$("#btn_hp_no_chk").prop("disabled", false);
			    		}
					}
				);			
			}		
			else{
				alert("사용가능한 핸드폰 번호 입니다");
			}
		}
	
		function goSave() {			
			var frm = document.main_form;
			
			var sResi_No =  $M.getValue("resi_no1") + $M.getValue("resi_no2");		
			$M.setValue("resi_no", sResi_No );	

		     // validation check
	     	if($M.validation(frm) == false) {
	     		return;
	     	}
		     		  
			if($M.getValue("web_id_chk") == "N") {
				alert("아이디 중복검사를 진행해주세요"); 
				return;
			}
	       	
			if($M.getValue("resi_no_chk") == "N" ) {
				alert("주민등록번호 중복검사를 진행해주세요"); 
				return;
			}
			
			if($M.getValue("hp_no_chk") == "N") {
				alert("핸드폰 번호 중복검사를 진행해주세요"); 
				return;
			}
	        	
			if($M.getValue("org_code") == "") {
				alert("부서는 필수입니다! "); 
				return;
			}
						
			if($M.getValue("org_auth_cd") == "") {
				alert("부서권한은 필수입니다! "); 
				return;
			}
						
			//console.log($M.toValueForm(frm));
			//console.log(frm);
			
			$M.goNextPageAjaxSave(this_page, $M.toValueForm(frm) , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			//사용자 목록 이동
						$M.goNextPage("/comm/comm0108");
					}
				}
			);
		}
		
		function fnClose() {
			window.close();
		}
		
		function fnList() {
			history.back();
		}
	
		function goPrintCertificate() {
			alert("경조급지급신청서 출력");
		}
		
		function goDocPrint() {
			alert("경력증명서 출력");
		}
				
		function goPrintShip() {
			alert("재직증명서 출력");
		}
		
	</script>
</head>
<body>
<!-- 팝업 -->
	<div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
						
	<form id="main_form" name="main_form" enctype="multipart/form-data" >
	<!-- contents 전체 영역 -->
		<div class="content-wrap">
	<!-- 상세페이지 타이틀 -->
	<!-- /상세페이지 타이틀 -->
			<div class="contents">
			<!-- 기본정보 -->			
				<input type="hidden" id="lastchk_web_id" 	name="lastchk_web_id"  		value="" >
				<input type="hidden" id="lastchk_hp_no" 	name="lastchk_hp_no" 		value=""  >
				<input type="hidden" id="lastchk_resi_no" 	name="lastchk_resi_no" 		value=""  >
				<input type="hidden" id="web_id_chk" 		name="web_id_chk" 			value="N" >
				<input type="hidden" id="hp_no_chk" 		name="hp_no_chk" 			value="N" >
				<input type="hidden" id="resi_no_chk" 		name="resi_no_chk" 			value="N" >		
				<input type="hidden" id="pic_file_seq" 		name="pic_file_seq" 		value="0" >
				<input type="hidden" name="upload_type" id="upload_type" value="${inputParam.upload_type }"/>
				
				<div>
					<div class="title-wrap">
						<h4>기본정보</h4>		
						<div>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>							
					</div>
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
								<th rowspan="5" class="text-center">										
									<div class="mb20" >
										프로필 사진
									</div>
									<div class="form-row inline-pd">
										<div class="col-12 ">
											<button type="button" id="fileAddBtn" class="btn btn-primary-gra"  onclick="javascript:goSearchFile()"  style="width: 100%;"   >사진 업로드</button>
										</div>	
										<div id="fileDiv" >
										</div>
									</div>	
								</th>									
								<td rowspan="5" class="text-center" >
								
									<div class="profilephoto-item"  onmouseover="javascript:fnDelBtnShow();" onmouseout="javascript:fnDelBtnHide();"  >
										<img id="profileImage" src="/static/img/icon-user.png" alt="프로필 사진" class="icon-profilephoto" style="width:150px;" />
											<div class="profilephoto-delete" style="display:none;" >
												<button type="button" id="fileRemoveBtn" class="btn btn-icon-md text-light"><i class="material-iconsclose font-16"></i></button>
											</div>							
									</div>
								</td>
								<th class="text-right essential-item">직원명(한글)</th>
								<td>
									<input type="text" class="form-control essential-bg width120px"  id="kor_name" name="kor_name" datatype="string" required="required" alt="직원명(한글)" maxlength="15" >
								</td>	
								<th class="text-right">직원명(영문)</th>
								<td>
									<input type="text" class="form-control width120px" id="eng_name" name="eng_name" datatype="string" maxlength="30" >
								</td>	
								<th class="text-right essential-item">아이디</th> 
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width120px">
											<input type="text" class="form-control essential-bg" id="web_id"  name="web_id" required="required" alt="아이디" minlength="6" maxlength="30" >
										</div>
										<div class="col width60px">
											<button type="button" id="btn_web_id_chk" class="btn btn-primary-gra" style="width: 100%;" onclick="javascript:goWebIdCheck();" >중복확인</button>
										</div>
									</div>										
								</td>
							</tr>
							<tr>
								<th class="text-right">주민등록번호</th>
								<td> 
									<div class="form-row inline-pd widthfix">
										<div class="col width70px">
											<input type="text" id="resi_no1" name="resi_no1" class="form-control" minlength="6" maxlength="6"  datatype="int"  >
										</div>
										<div class="col width16px text-center">~</div>
										<div class="col width70px">
											<input type="password" id="resi_no2" name="resi_no2" class="form-control" minlength="7" maxlength="7" datatype="int"  alt="주민번호 뒷자리" >
										</div>

										<div class="col width60px"  >
											<button type="button" id="btn_resi_no_chk" class="btn btn-primary-gra" style="width: 100%;" onclick="javascript:goResiNoCheck();" >중복확인</button>
										</div>
									</div>
								</td>		
								<th class="text-right essential-item">생년월일</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width120px">
											<div class="input-group">
												<input type="text" id="birth_dt" name="birth_dt" dateFormat="yyyy-MM-dd" class="form-control border-right-0 essential-bg calDate"  required="required" alt="생년월일"  >
											</div>
										</div>
										<div class="col width120px pl5">
											<div class="form-check form-check-inline"  style="margin-right: 0px;">
												<input class="form-check-input" type="radio" name="solar_cal_yn" value="Y" checked="checked" >
												<label class="form-check-label">양력</label>
											</div>
											<div class="form-check form-check-inline"style="margin-right: 0px;">
												<input class="form-check-input" type="radio" name="solar_cal_yn" value="N" >
												<label class="form-check-label">음력</label>
											</div>
										</div>
									</div>
								</td>		
								<th class="text-right essential-item">입사일자</th>
								<td>
									<div class="input-group width120px">
										<input type="text" id="ipsa_dt" name="ipsa_dt" dateFormat="yyyy-MM-dd" class="form-control border-right-0 essential-bg calDate" required="required" alt="입사일자" >
									</div>
								</td>							
							</tr>
							<tr>
								<th class="text-right essential-item">핸드폰</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width140px">
											<input type="text" class="form-control essential-bg" id="hp_no" name="hp_no"  format="phone"  required="required"  required="required" alt="핸드폰"  >
										</div>
										<div class="col width60px">
											<button type="button" id="btn_hp_no_chk"    class="btn btn-primary-gra" style="width: 100%;" onclick="javascript:goHpNoCheck();" >중복확인</button>
										</div>
									</div>
								</td>		
								<th class="text-right essential-item">비상연락처</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-6">
											<input type="text" class="form-control essential-bg" id="emergency_contact_relation" name="emergency_contact_relation" placeholder="비상연락처관계"   datatype="string" required="required" alt="비상연락처관계" >
										</div>
										<div class="col-6">
											<input type="text" class="form-control essential-bg" id="emergency_contact_phone_no" name="emergency_contact_phone_no"  placeholder="-없이 숫자만" datatype="int" minlength="9"  maxlength="12" required="required" alt="비상연락처" >
										</div>
									</div>
								</td>		
								<th class="text-right">이메일</th>
								<td>
									<input type="text" class="form-control width140px"  id="email" name="email"  format="email" >
								</td>							
							</tr>
							<tr>							
								<th class="text-right essential-item">부서</th>
								<td >
									<input class="form-control" style="width: 99%;"type="text" id="org_code" name="org_code" easyui="combogrid"
										easyuiname="orgAllDepthList" panelwidth="350" textfield="path_org_name" multi="N" idfield="org_code" />
								</td>															
								<th class="text-right">전화(사무실)</th>
								<td>
									<input type="text" class="form-control width140px"  id="office_tel_no" name="office_tel_no" placeholder="-없이 숫자만" datatype="int" minlength="9"  maxlength="12" >
								</td>	
								<th class="text-right">전화(팩스)</th>
								<td>
									<input type="text" class="form-control width140px"  id="office_fax_no" name="office_fax_no" placeholder="-없이 숫자만"  datatype="int" minlength="9"  maxlength="12" >
								</td>						
							</tr>
							<tr>
								<th class="text-right essential-item">부서권한</th>
								<td>
									<input class="form-control essential-bg" style="width: 99%;" type="text" id="org_auth_cd" name="org_auth_cd" easyui="combogrid"
										easyuiname="org2DepthList" panelwidth="350" multi="Y" idfield="org_code" textfield="org_name" />
								</td>
								<th class="text-right">업무권한</th>
								<td colspan="3">
									<input class="form-control" style="width:400px" type="text" id="job_auth_cd" name="job_auth_cd" easyui="combogrid"
										easyuiname="jobAuthList" panelwidth="400" multi="Y" idfield="code_value" textfield="code_name"/>
								</td>					
							</tr>
							<tr>
								<th class="text-right essential-item">재직구분</th>
								<td>									
									<select class="form-control essential-bg" id="work_status_cd" name="work_status_cd"   required="required" alt="재직구분" >
										<option value="">- 선택 -</option>
										<c:forEach items="${codeMap['WORK_STATUS']}" var="item">
											<option value="${item.code_value}" ${item.code_value == '01'? 'selected' : '' }>
												${item.code_name}
											</option>
										</c:forEach>	
									</select>									
								</td>									
								<th class="text-right essential-item">직급</th>
								<td class="pr">
									<div class="form-row inline-pd pr">
										<div class="col-12">
											<select class="form-control essential-bg" id="grade_cd" name="grade_cd"  required="required" alt="직급" >
												<option value="">- 선택 -</option>
												<c:forEach items="${codeMap['GRADE']}" var="item">
													<option value="${item.code_value}" >
														${item.code_name}
													</option>
												</c:forEach>
											</select>
										</div>
									</div>
								</td>																	
								<th rowspan="3" class="text-right essential-item">자택주소</th>
								<td colspan="3" rowspan="3">
									<div class="form-row inline-pd mb7 widthfix">
										<div class="col width100px">
											<input type="text" class="form-control essential-bg"   id="home_post_no" name="home_post_no"  readonly="readonly"  required="required"   alt="자택주소" >
										</div>
										<div class="col width60px">
											<button type="button" class="btn btn-primary-gra"  onclick="javascript:openSearchAddrPanel('fnJusoBiz');" >주소찾기</button>
										</div>
									</div>
									<div class="form-row inline-pd mb7">
										<div class="col-12">
											<input type="text" class="form-control essential-bg"  id="home_addr1" name="home_addr1" readonly="readonly"  required="required"   alt="자택주소" >
										</div>
									</div>
									<div class="form-row inline-pd">
										<div class="col-12">
											<input type="text" class="form-control essential-bg"  id="home_addr2" name="home_addr2" >
										</div>
									</div>
								</td>												
							</tr>
							<tr>	
								<th class="text-right">퇴직일</th>
								<td>
									<div class="input-group width120px" id="retireField" name="retireField">
										<input type="text" id="retire_dt" name="retire_dt" dateFormat="yyyy-MM-dd" class="form-control border-right-0 calDate" alt="퇴직일" >
									</div>
								</td>	
								<th class="text-right essential-item">직책</th>
								<td>
									<select class="form-control essential-bg" id="job_cd" name="job_cd"   required="required" alt="직책" >
										<option value="">- 선택 -</option>
										<c:forEach items="${codeMap['JOB']}" var="item">
											<option value="${item.code_value}">
												${item.code_name}
											</option>
										</c:forEach>	
									</select>
								</td>									
							</tr>
							<tr>
								<th class="text-right">퇴직 시 회사의견</th>
								<td colspan="3">
									<input type="text" class="form-control" id="cert_company_opinion" name="cert_company_opinion" readonly="readonly" alt ="퇴직 시 회사의견"  >
								</td>	
							</tr>														
						</tbody>
					</table>
				</div>					
<!-- /기본정보 -->	
				<div class="btn-group mt10">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
			</div>	
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>					
		</div>		
<!-- /contents 전체 영역 -->	
	</form>
</div>
</body>
</html>