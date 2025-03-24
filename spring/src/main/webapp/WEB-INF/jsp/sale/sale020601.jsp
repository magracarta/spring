<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include
	page="/WEB-INF/jsp/common/commonForAll.jsp" /><%@ taglib prefix="c"
	uri="http://java.sun.com/jstl/core_rt"%><%@ taglib prefix="fn"
	uri="http://java.sun.com/jsp/jstl/functions"%><%@ taglib prefix="fmt"
	uri="http://java.sun.com/jsp/jstl/fmt"%><%@ taglib
	uri="http://www.springframework.org/tags" prefix="spring"%><%@ taglib
	uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비코드관리 > 장비코드관리 > 장비코드등록 > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-03-25 10:52:36
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp" />
	<style>
		.form-check-inline {
			display: -ms-inline-flexbox;
			display: inline-flex;
			-ms-flex-align: center;
			align-items: center;
			padding-left: 0;
			margin-right: .5rem;
			padding-top: 1px
		}
	</style>
	<script type="text/javascript">
		var moneyUnitJson = JSON.parse('${codeMapJsonObj["MONEY_UNIT"]}'); // 화폐단위
		var machineSubTypeMap = ${machineSubTypeMap};  // 기종에따른 규격 LIST
		var list = ${list};  // 기존 모델과 LIST - 새로등록할 모델과 중복검사 위해

		// 첨부파일의 index 변수
		var chartFileIndex = 1;
		// 첨부할 수 있는 파일의 개수
		var chartFileMaxCount = 3;

		// 첨부파일의 index 변수
		var fileIndex = 1;
		// 첨부할 수 있는 파일의 개수
		var fileCount = 1;

		function fnAddFile() {
			if($("input[name='file_seq']").size() >= fileCount) {
				alert("파일은 " + fileCount + "개만 첨부하실 수 있습니다.");
				return false;
			}
			openFileUploadPanel('setFileInfo', 'upload_type=SERVICE&file_type=etc&max_size=5048&file_ext_type=pdf');
		}

		function setFileInfo(result) {
			var str = '';
			str += '<div class="table-attfile-item file_' + fileIndex + '" style="float:left; display:block;">';
			str += '<a href="javascript:fileDownload(' + result.file_seq + ');" style="color: blue;">' + result.file_name + '</a>&nbsp;';
			str += '<input type="hidden" name="file_seq" value="' + result.file_seq + '"/>';
			str += '<button type="button" class="btn-default" onclick="javascript:fnRemoveFile(' + fileIndex + ', ' + result.file_seq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
			str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
			str += '</div>';
			$('.file_div').append(str);
			fileIndex++;
		}

		// 첨부파일 삭제
		function fnRemoveFile(fileIndex, fileSeq) {
			var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
			if (result) {
				$(".file_" + fileIndex).remove();
			} else {
				return false;
			}

		}

		// 뒤로가기, 목록
		function fnList() {
			history.back();
		}

		// 기종에 따른 규격 세팅
		function fnMachineSubTypeList() {
			var machineTypeCd = $M.getValue("machine_type_cd");
			console.log("machineTypeCd : ", machineTypeCd);
			// select box 옵션 전체 삭제
			$("#machine_sub_type_cd option").remove();
			// select box option 추가
			$("#machine_sub_type_cd").append(new Option('- 선택 -', ""));

			// 기종에 따른 규격 list를 세팅
			if (machineSubTypeMap.hasOwnProperty(machineTypeCd)) {
				var machineSubTypeCdList = machineSubTypeMap[machineTypeCd];
				console.log("machineSubTypeCdList : " , machineSubTypeCdList);
				for (item in machineSubTypeCdList) {
					$("#machine_sub_type_cd").append(new Option(machineSubTypeCdList[item].code_name, machineSubTypeCdList[item].code));
				}
			}
		}

		// 단가관리 팝업  T_MACHINE_PRICE
		// 등록페이지에서 단가관리 팝업 연결 X  상세에서만 가능.
		function fnMachinePricePopup() {
			alert("저장 후 등록해주세요.");
		}

		// 저장
		function goSave() {
			var param = {
				machine_name : $M.getValue("machine_name")
			}
			$M.goNextPageAjax(this_page + '/duplicate/check/', $M.toGetParam(param), {method : 'GET'},
			// $M.goNextPageAjax(this_page + '/duplicate/check/' + machineName + '/', $M.toGetParam({}), {method : 'GET'}, // 모델명 안에 '/'가 들어오는 경우가 있어 사용안함
					function(result) {
			    		if(result.success) {
							var frm = document.main_form;

							// validation check
							if($M.validation(document.main_form) == false) {
								return;
							};

							// if($M.getValue("machine_group_cd")==""){
							// 	alert("씨리즈는 필수선택입니다.");
							// 	return;
							// }

							$M.setValue("machine_group_name", $("#machine_group_cd").combogrid("getText"));

							$M.goNextPageAjaxSave(this_page + "/save", $M.toValueForm(frm) , {method : 'POST'},
								function(result) {
						    		if(result.success) {
						    			$M.goNextPage("/sale/sale0206");
									}
								}
							);
						} else {
							return;
						}
					}
				);
		}


		// 기간차트 첨부파일열기
		function goSearchFile(){
			if($("input[class='job_file_list']").size() >= chartFileMaxCount) {
				alert("파일은 " + chartFileMaxCount + "개만 첨부하실 수 있습니다.");
				return false;
			}

            var param = {
                max_width: 768,
                max_height: 1024,
                upload_type: 'SERVICE',
                file_type: 'img',
                max_size: 300
            };

			openFileUploadPanel('fnPrintFileInfo', $M.toGetParam(param));
		}

		function fnPrintFileInfo(result) {
			setFileInfo1(result.file_seq, result.file_name)
		}

		//첨부파일 세팅
		function setFileInfo1(fileSeq, fileName) {
			var str = '';
			str += '<div class="table-attfile-item chart_file_' + chartFileIndex + '" style="float:left; display:block;">';
			str += '<a href="javascript:fileDownload(' + fileSeq + ');" style="color: blue;">' + fileName + '</a>&nbsp;';
			str += '<input type="hidden" class="job_file_list" name="job_file_seq_'+ chartFileIndex + '" value="' + fileSeq + '"/>';
			str += '<button type="button" class="btn-default" onclick="javascript:fnRemoveFile1(' + chartFileIndex + ', ' + fileSeq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
			str += '</div>';
			$('.chart_file_div').append(str);
			chartFileIndex++;
		}

		// 첨부파일 삭제
		function fnRemoveFile1(chartFileIndex, fileSeq) {
			var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
			if (result) {
				$(".chart_file_" + chartFileIndex).remove();
				$("#job_file_seq_" + chartFileIndex).remove();
			} else {
				return false;
			}
		}

		function fnMoneyUnitChanged(codeValue) {
			
			alert('화폐구분이 있는 경우 동일한 메이커는 같은 화폐구분으로 적용됩니다.');
			fnMoneyNameChange(codeValue);
		}

		function fnMoneyNameChange(codeValue){
			var item;
			if(codeValue) {
				item = moneyUnitJson.filter(item => item.code_value === codeValue)[0];
			}
			
			var money_unit = "원";
			if(item) {
				money_unit = item.code_desc;
			}
			// switch($M.getValue("money_unit_cd")){
			// 	case "JPY" :
			// 		money_unit = "엔(Y)";
			// 		break;
			// 	case "USD" :
			// 		money_unit = "달러($)";
			// 		break;
			// 	case "CNY" :
			// 		money_unit = "위안(C)";
			// 		break;
			// 	case "EUR" :
			// 		money_unit = "유로(E)";
			// 		break;
			// }
			$("#order_price_name").html(money_unit);
		}

		// 업무DB 연결 함수 21-08-31이강원
     	function openWorkDB(){
     		openWorkDBPanel('',$M.getValue("machine_plant_seq"));
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
							<button type="button" class="btn btn-outline-light" onclick="javascript:fnList()"><i class="material-iconskeyboard_backspace text-default"></i></button>
							<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp" />
						</div>
					</div>
					<!-- /상세페이지 타이틀 -->
					<div class="contents">
						<!-- 상단 폼테이블 -->
						<div>
							<table class="table-border">
								<colgroup>
									<col width="100px">
									<col width="">
									<col width="100px">
									<col width="">
									<col width="100px">
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right essential-item">모델명 / 형식명</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col-5">
													<input type="hidden" id="machine_plant_seq" name="machine_plant_seq" value="">
													<input type="text" class="form-control essential-bg width180px" id="machine_name" name="machine_name" alt="모델명" required="required" maxlength="50" placeholder="모델명">
												</div>
												<div class="col-5">
													<input type="text" class="form-control" id="machine_form_name" name="machine_form_name" alt="형식명" maxlength="50" placeholder="형식명">
												</div>
												<div class="col-auto">
							                        <button type="button" class="btn btn-primary-gra" onclick="javascript:openWorkDB();">업무DB</button>
									            </div>
											</div>
											<input type="hidden" id="machine_group_name" name="machine_group_name">
										</td>
										<th class="text-right essential-item">기종/규격</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col-4">
													<select id="machine_type_cd" name="machine_type_cd" class="form-control essential-bg width240px" alt="기종" required="required" onchange="javascript:fnMachineSubTypeList();">
														<option value="">- 선택 -</option>
														<c:forEach items="${codeMap['MACHINE_TYPE']}" var="item">
															<option value="${item.code_value}">${item.code_name}</option>
														</c:forEach>
													</select>
												</div>
												<div class="col-3">
													<select id="machine_sub_type_cd" name="machine_sub_type_cd" class="form-control essential-bg width160px" alt="규격" required="required">
														<option value="">- 선택 -</option>
													</select>
												</div>
											</div>
										</td>
										<th class="text-right">일괄발송서류</th>
										<td>
											<div class="table-attfile file_div" style="width:100%;">
												<div class="table-attfile" style="float:left">
												<button type="button" class="btn btn-primary-gra mr10" name="fileAddBtn" id="fileAddBtn" onclick="javascript:fnAddFile();">파일찾기</button>
												&nbsp;&nbsp;
												<c:if test="${not empty pro.file.file_seq }">
													<div class="table-attfile-item file_1" style="float:left; display:block;">
														<a href="javascript:fileDownload('${pro.file.file_seq}');" style="color: blue;">${pro.file.origin_file_name}</a>&nbsp;
														<input type="hidden" name="file_seq" value="${pro.file.file_seq}"/>
														<button type="button" class="btn-default" onclick="javascript:fnRemoveFile('1', '${pro.file.file_seq}')"><i class="material-iconsclose font-18 text-default"></i></button>
													</div>
												</c:if>
												</div>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right essential-item">메이커 / 씨리즈</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col-5">
													<select id="maker_cd" name="maker_cd" class="form-control essential-bg width120px" alt="메이커" required="required">
														<option value="">- 선택 -</option>
														<c:forEach items="${makerList}" var="item">
															<option value="${item.code_value}">${item.code_name}</option>
														</c:forEach>
													</select>
												</div>
												<div class="col-5">
														<input class="form-control essential-bg width180px" style="width:150px;" type="text" id="machine_group_cd" name="machine_group_cd" easyui="combogrid"
									   					easyuiname="machineGroupList" panelwidth="150" idfield="code_value" textfield="code_name" multi="N" value=""/>
												</div>
											</div>
										</td>
										<th class="text-right essential-item">판매진행</th>
										<td>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" name="sale_yn" value="Y" checked="checked">
												<label class="form-check-label">Y</label>
											</div>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" name="sale_yn" value="N">
												<label class="form-check-label">N</label>
											</div>
										</td>
										<th class="text-right essential-item">원동기형식1</th>
										<td>
											<input type="text" class="form-control essential-bg width140px" alt="원동기형식1" id="motor_type" name="motor_type" required="required">
										</td>
									</tr>
									<tr>
										<th class="text-right essential-item">발주단가</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col-3">
													<input type="text" class="form-control text-right essential-bg width120px" alt="발주단가" id="order_price" name="order_price" datatype="int" required="required" format="num">
												</div>
												<div class="col-2" id="order_price_name">원</div>
											</div>
										</td>
										<th class="text-right">화폐구분</th>
										<td>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" id="money_unit_init" name="money_unit_cd" onclick="javascript:fnMoneyUnitChanged()" value="" checked="checked"> <label
													class="form-check-label" for="money_unit_init">없음</label>
											</div>
											<%-- [재호 - Q&A 15585] 화폐구분 통일 --%>
											<c:forEach var="item" items="${codeMap['MONEY_UNIT']}">
												<div class="form-check form-check-inline">
													<input class="form-check-input" type="radio" id="money_unit_${item.code_value}" name="money_unit_cd" onclick="javascript:fnMoneyUnitChanged('${item.code_value}')" value="${item.code_value}">
													<label class="form-check-label" for="money_unit_${item.code_value}">${item.code_desc}</label>
												</div>
											</c:forEach>
<%--											<div class="form-check form-check-inline">--%>
<%--												<input class="form-check-input" type="radio" id="money_unit_krw" name="money_unit_cd" onclick="javascript:fnMoneyUnitChanged()" value="KRW">--%>
<%--												<label class="form-check-label" for="money_unit_krw">원(W)</label>--%>
<%--											</div>--%>
<%--											<div class="form-check form-check-inline">--%>
<%--												<input class="form-check-input" type="radio" id="money_unit_jpy" name="money_unit_cd" onclick="javascript:fnMoneyUnitChanged()" value="JPY">--%>
<%--												<label class="form-check-label" for="money_unit_jpy">엔(Y)</label>--%>
<%--											</div>--%>
<%--											<div class="form-check form-check-inline">--%>
<%--												<input class="form-check-input" type="radio" id="money_unit_usd" name="money_unit_cd" onclick="javascript:fnMoneyUnitChanged()" value="USD">--%>
<%--												<label class="form-check-label" for="money_unit_usd">달러($)</label>--%>
<%--											</div>--%>
<%--											<div class="form-check form-check-inline">--%>
<%--												<input class="form-check-input" type="radio" id="money_unit_cny" name="money_unit_cd" onclick="javascript:fnMoneyUnitChanged()" value="CNY">--%>
<%--												<label class="form-check-label" for="money_unit_cny">위안(C)</label>--%>
<%--											</div>--%>
<%--											<div class="form-check form-check-inline">--%>
<%--												<input class="form-check-input" type="radio" id="money_unit_eur" name="money_unit_cd" onclick="javascript:fnMoneyUnitChanged()" value="EUR">--%>
<%--												<label class="form-check-label" for="money_unit_eur">유로(E)</label>--%>
<%--											</div>--%>
										</td>
										<th class="text-right">원동기형식2</th>
										<td>
											<input type="text" class="form-control width140px" alt="원동기형식2" id="motor_type_2" name="motor_type_2">
										</td>
									</tr>
									<tr>
										<th class="text-right">출하단가</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col-3">
													<input type="text" class="form-control text-right width120px" readonly>
												</div>
												<div class="col-2" id="order_price_name">원</div>
											</div>
										</td>
										<th class="text-right">적용일자</th>
										<td><input type="text" class="form-control width120px" readonly>
										</td>
										<th class="text-right essential-item">사용여부</th>
										<td>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" name="use_yn" value="Y" checked="checked">
												<label class="form-check-label">사용</label>
											</div>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" name="use_yn" value="N">
												<label class="form-check-label">사용안함</label>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right">정상판가</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col-3">
													<input type="text" class="form-control text-right width120px" readonly>
												</div>
												<div class="col-2">원</div>
											</div>
										</td>
										<th class="text-right">CAP적용대상</th>
										<td>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" name="cap_yn" value="Y" checked="checked">
												<label class="form-check-label">적용</label>
											</div>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" name="cap_yn" value="N">
												<label class="form-check-label">미적용</label>
											</div>
										</td>
										<th class="text-right essential-item">YK취급여부</th>
										<td>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" name="yk_sale_yn" value="Y" checked="checked">
												<label class="form-check-label">Y</label>
											</div>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" name="yk_sale_yn" value="N">
												<label class="form-check-label">N</label>
											</div>
										</td>
									</tr>
									<tr>
										<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
										<%--<th class="text-right">대리점가</th>--%>
										<th class="text-right">위탁판매점가</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col-3">
													<input type="text" class="form-control text-right width120px" readonly>
												</div>
												<div class="col-2">원</div>
											</div>
										</td>
										<th class="text-right">센터DI적용대상</th>
										<td>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" name="center_di_yn" value="Y" checked="checked">
												<label class="form-check-label">적용</label>
											</div>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" name="center_di_yn" value="N">
												<label class="form-check-label">미적용</label>
											</div>
										</td>
										<th class="text-right essential-item">SA-R적용대상</th>
										<td>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" name="sar_yn" value="Y" checked="checked">
												<label class="form-check-label">적용</label>
											</div>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" name="sar_yn" value="N">
												<label class="form-check-label">미적용</label>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right">할인한도</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col-3">
													<input type="text" class="form-control text-right width140px" readonly>
												</div>
												<div class="col-2">원</div>
											</div>
										</td>
										<th class="text-right">정기검사주기</th>
										<td><input type="text" class="form-control width60px" id="check_cycle_year" name="check_cycle_year" datatype="int"></td>
										<th class="text-right">구코드</th>
										<td>
											<input type="text" class="form-control width140px" id="old_machine_name" name="old_machine_name">
										</td>
									</tr>
									<tr>
							<th class="text-right">기간차트 첨부</th>
							<td>
								<div class="table-attfile chart_file_div" style="width:100%;">
									<div class="table-attfile" style="float:left">
										<button type="button" class="btn btn-primary-gra mr10" name="fileAddBtn1" id="fileAddBtn1" onclick="javascript:goSearchFile();">파일찾기</button>&nbsp;&nbsp;
									</div>
								</div>
							</td>
							<th class="text-right">출하증명서발급</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="out_certi_yn" value="Y" ${map.out_certi_yn eq 'Y' ? 'checked' : '' }>
									<label class="form-check-label">적용</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="out_certi_yn" value="N" ${map.out_certi_yn eq 'N' ? 'checked' : '' }>
									<label class="form-check-label">미적용</label>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">사용유종</th>
							<td>
								<input type="text" class="form-control width240px" id="use_oil" name="use_oil" value="${map.use_oil}" maxlength="15">
							</td>
							<th class="text-right">총중량</th>
							<td>
								<input type="text" class="form-control width240px" id="total_weight" name="total_weight" value="${map.total_weight}" maxlength="15">
							</td>
							<th></th>
							<td></td>
						</tr>
						<tr>
							<th class="text-right">상용출력</th>
							<td>
								<input type="text" class="form-control width240px" id="normal_power" name="normal_power" value="${map.normal_power}" maxlength="15">
							</td>
							<th class="text-right">규격</th>
							<td>
								<input type="text" class="form-control width240px" id="mch_std" name="mch_std" value="${map.mch_std}" maxlength="15">
							</td>
							<th></th>
							<td></td>
						</tr>
								</tbody>
							</table>
						</div>
						<!-- /상단 폼테이블 -->
						<!-- 그리드 서머리, 컨트롤 영역 -->
						<div class="btn-group mt5">
							<div class="right">
								<button type="button" class="btn btn-info" onclick="javascript:fnMachinePricePopup()">단가관리</button>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param
										name="pos" value="BOM_R" /></jsp:include>
							</div>
						</div>
						<!-- /그리드 서머리, 컨트롤 영역 -->
					</div>
				</div>
				<jsp:include page="/WEB-INF/jsp/common/footer.jsp" />
			</div>
			<!-- /contents 전체 영역 -->
		</div>
	</form>
</body>
</html>
